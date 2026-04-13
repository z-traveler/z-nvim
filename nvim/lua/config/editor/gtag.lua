local M = {}

M.config = {
  bin = "gtags",
  gtagslabel = "pygments",
  gtagsconf = vim.fn.expand("$HOME/share/gtags/gtags.conf"),
  cache_dir = vim.fn.stdpath("data") .. "/gtags/",
  filetypes = { "python", "javascript", "typescript", "c", "cpp", "rust", "go", "java" },
  root_markers = { ".git", ".svn", ".lazy.lua" },
  skip_patterns = {}, -- 排除路径模式，如 {"*/Data/*", "*/Lib/*"}
  max_filesize = nil, -- 排除超大文件，如 "500k"
}

M.state = {
  setup = false,
  update_timer = nil,
  is_generating = false,
  generation_failed = false, -- 生成失败/超时后禁止自动重试，需手动 :GtagsGenerate
  debug = false,
}

function M.get_project_root()
  return LazyVim.root()
end

function M.get_project_id(project_root)
  return project_root:gsub("/", "_")
end

function M.get_cache_path(project_root)
  local project_id = M.get_project_id(project_root)
  return M.config.cache_dir .. project_id .. "/"
end

function M.ensure_cache_dir(cache_path)
  vim.fn.mkdir(cache_path, "p")
end

function M.has_gtags_db(cache_path)
  if vim.fn.filereadable(cache_path .. "GTAGS") == 0 then
    return false
  end
  if vim.fn.getfsize(cache_path .. "GTAGS") <= 0 then
    return false
  end
  return true
end

function M.async_execute(cmd, cwd, env, callback)
  -- 合并自定义环境变量到系统环境，避免丢失 PATH 等
  local merged_env = vim.fn.environ()
  if env then
    for k, v in pairs(env) do
      merged_env[k] = v
    end
  end
  local stderr_buf = {}
  local job_id = vim.fn.jobstart(cmd, {
    cwd = cwd,
    env = merged_env,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        if callback then
          callback(exit_code, stderr_buf)
        end
      end)
    end,
    on_stdout = function(_, data) end,
    on_stderr = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then
          table.insert(stderr_buf, line)
        end
      end
    end,
  })
  return job_id
end

function M.generate_full(project_root, cache_path, callback)
  if M.state.is_generating then
    return
  end

  M.state.is_generating = true
  M.ensure_cache_dir(cache_path)
  local job_id
  local timed_out = false
  local timeout_timer = vim.fn.timer_start(600000, function()
    timed_out = true
    M.state.is_generating = false
    M.state.generation_failed = true
    if job_id then
      vim.fn.jobstop(job_id)
    end
    vim.schedule(function()
      vim.notify("gtags generation timeout (10min), killed. Run :GtagsGenerate to retry.", vim.log.levels.WARN)
    end)
  end)
  local env = {
    GTAGSROOT = project_root,
    GTAGSDBPATH = cache_path,
    GTAGSLABEL = M.config.gtagslabel,
    GTAGSCONF = M.config.gtagsconf,
  }

  -- 有过滤配置时，先用 find 生成文件列表（相对路径，pygments 需要）
  local cmd = { M.config.bin }
  if #M.config.skip_patterns > 0 or M.config.max_filesize then
    local list_path = cache_path .. "gtags.files"
    local find_parts = { "find", vim.fn.shellescape(project_root), "-not -path '*/.svn/*'", "-type f" }
    for _, pat in ipairs(M.config.skip_patterns) do
      table.insert(find_parts, "-not -path " .. vim.fn.shellescape(pat))
    end
    if M.config.max_filesize then
      table.insert(find_parts, "-size -" .. M.config.max_filesize)
    end
    -- 转换为相对路径（去掉 project_root 前缀）
    local strip = vim.fn.shellescape("s|^" .. project_root .. "/||")
    local find_cmd = table.concat(find_parts, " ") .. " 2>/dev/null | sed " .. strip .. " > " .. vim.fn.shellescape(list_path)
    vim.fn.system(find_cmd)
    table.insert(cmd, "-f")
    table.insert(cmd, list_path)
  end
  table.insert(cmd, cache_path)
  vim.notify("Generating gtags database for project...", vim.log.levels.INFO)

  job_id = M.async_execute(cmd, project_root, env, function(exit_code, stderr)
    vim.fn.timer_stop(timeout_timer)
    M.state.is_generating = false
    if timed_out then
      return
    end
    if exit_code == 0 then
      vim.notify("GTAGS database generated successfully", vim.log.levels.INFO)
    else
      M.state.generation_failed = true
      local msg = "Failed to generate GTAGS database"
      if #stderr > 0 then
        msg = msg .. "\n" .. table.concat(stderr, "\n")
      end
      vim.notify(msg, vim.log.levels.ERROR)
    end
    if callback then
      callback(exit_code)
    end
  end)
end

function M.update_incremental(opts)
  opts = opts or {}
  local cache_path = opts.cache_path
  local project_root = opts.project_root
  local callback = opts.callback
  local filepath = opts.filepath
  if not M.has_gtags_db(cache_path) then
    return M.generate_full(project_root, cache_path, callback)
  end

  local env = {
    GTAGSROOT = project_root,
    GTAGSDBPATH = cache_path,
    GTAGSLABEL = M.config.gtagslabel,
    GTAGSCONF = M.config.gtagsconf,
  }

  local cmd
  if filepath then
    local relative_path = filepath:sub(#project_root + 2)
    cmd = { "global", "--single-update", relative_path }
  else
    cmd = { "global", "-u" }
  end

  if M.state.debug then
    vim.notify("Updating gtags database with incremental..." .. vim.inspect(cmd), vim.log.levels.DEBUG)
  end
  local st = vim.loop.hrtime()
  return M.async_execute(cmd, project_root, env, function(exit_code, stderr)
    local et = vim.loop.hrtime()
    local dr = (et - st) / 1000000
    if exit_code == 0 then
      if M.state.debug then
        vim.notify("Updating gtags database with incremental done: " .. tostring(dr) .. "ms", vim.log.levels.DEBUG)
      end
      if callback then
        callback(exit_code)
      end
    else
      local msg = "Failed to update GTAGS database"
      if #stderr > 0 then
        msg = msg .. "\n" .. table.concat(stderr, "\n")
      end
      vim.notify(msg, vim.log.levels.WARN)
    end
  end)
end

function M.update_or_generate(opts)
  if M.state.is_generating then
    return
  end
  if M.state.generation_failed then
    return
  end

  local project_root = M.get_project_root()
  local cache_path = M.get_cache_path(project_root)

  local current_ft = vim.bo.filetype
  local should_process = false
  for _, ft in ipairs(M.config.filetypes) do
    if current_ft == ft then
      should_process = true
      break
    end
  end

  if not should_process then
    return
  end

  opts = opts or {}
  opts = vim.tbl_deep_extend("force", opts, { project_root = project_root, cache_path = cache_path })
  if M.has_gtags_db(cache_path) then
    M.update_incremental(opts)
  else
    M.generate_full(project_root, cache_path)
  end
end

function M.deboundced_update_or_generate(opts)
  if M.state.update_timer then
    vim.fn.timer_stop(M.state.update_timer)
  end
  M.state.update_timer = vim.fn.timer_start(500, function()
    M.state.update_timer = nil
    M.update_or_generate(opts)
  end)
end

function M.regenerate()
  local project_root = M.get_project_root()
  local cache_path = M.get_cache_path(project_root)
  M.state.generation_failed = false
  vim.fn.delete(cache_path, "rf")
  M.generate_full(project_root, cache_path)
end

function M.get_gtags_env()
  local project_root = M.get_project_root()
  local cache_path = M.get_cache_path(project_root)

  if not M.has_gtags_db(cache_path) then
    return nil
  end

  return {
    GTAGSROOT = project_root,
    GTAGSDBPATH = cache_path,
    GTAGSLABEL = M.config.gtagslabel,
    GTAGSCONF = M.config.gtagsconf,
  }
end

function M.setup_autocmds()
  local group = vim.api.nvim_create_augroup("GtagsManager", { clear = true })

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = "*",
    callback = function(args)
      local filepath = vim.fn.fnamemodify(args.file, ":p")
      vim.defer_fn(function()
        M.deboundced_update_or_generate({ filepath = filepath })
      end, 100)
    end,
  })
end

function M.setup_commands()
  vim.api.nvim_create_user_command("GtagsDebugToggle", function()
    if M.state.debug then
      M.state.debug = false
    else
      M.state.debug = true
    end
    vim.notify("Gtags debug toggled: " .. tostring(M.state.debug), vim.log.levels.INFO)
  end, { desc = "Toggle gtags debug" })

  vim.api.nvim_create_user_command("GtagsGenerate", function()
    M.regenerate()
  end, { desc = "Regenerate gtags database" })

  vim.api.nvim_create_user_command("GtagsUpdate", function()
    M.update_or_generate()
  end, { desc = "Update gtags database" })

  vim.api.nvim_create_user_command("GtagsInfo", function()
    local project_root = M.get_project_root()
    local cache_path = M.get_cache_path(project_root)
    print("Project root: " .. project_root)
    print("Cache path: " .. cache_path)
    print("Has gtags db: " .. tostring(M.has_gtags_db(cache_path)))
  end, { desc = "Show gtags info" })
end

function M.setup(opts)
  if opts then
    M.config = vim.tbl_deep_extend("force", M.config, opts)
  end
  M.state.setup = true
  M.setup_autocmds()
  M.setup_commands()
end

return M
