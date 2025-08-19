local M = {}

M.config = {
  bin = "gtags",
  gtagslabel = "native-pygments",
  gtagsconf = vim.fn.expand("$HOME/share/gtags/gtags.conf"),
  cache_dir = vim.fn.stdpath("data") .. "/gtags/",
  filetypes = { "python", "javascript", "typescript", "c", "cpp", "rust", "go", "java" },
  root_markers = { ".git", ".svn", ".lazy.lua" },
}

M.state = {
  steuped = false,
  update_timer = nil,
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
  local job_id = vim.fn.jobstart(cmd, {
    cwd = cwd,
    env = env,
    on_exit = function(_, exit_code)
      vim.schedule(function()
        if callback then
          callback(exit_code)
        end
      end)
    end,
    on_stdout = function(_, data)
      -- 可选：处理输出
    end,
    on_stderr = function(_, data)
      -- 可选：处理错误输出
      if #data > 1 or (data[1] and data[1] ~= "") then
        vim.schedule(function()
          vim.notify("gtags error: " .. table.concat(data, "\n"), vim.log.levels.WARN)
        end)
      end
    end,
  })
  return job_id
end

function M.generate_full(project_root, cache_path, callback)
  M.ensure_cache_dir(cache_path)
  local env = {
    GTAGSLABEL = M.config.gtagslabel,
    GTAGSCONF = M.config.gtagsconf,
  }
  local cmd = { M.config.bin, cache_path }
  vim.notify("Generating gtags database for project...", vim.log.levels.INFO)

  return M.async_execute(cmd, project_root, env, function(exit_code)
    if exit_code == 0 then
      vim.notify("GTAGS database generated successfully", vim.log.levels.INFO)
    else
      vim.notify("Failed to generate GTAGS database", vim.log.levels.ERROR)
    end
    if callback then
      callback(exit_code)
    end
  end)
end

function M.update_incremental(project_root, cache_path, callback)
  if not M.has_gtags_db(cache_path) then
    return M.generate_full(project_root, cache_path, callback)
  end

  local env = {
    GTAGSROOT = project_root,
    GTAGSDBPATH = cache_path,
    GTAGSLABEL = M.config.gtagslabel,
    GTAGSCONF = M.config.gtagsconf,
  }

  local cmd = { "global", "-u" }

  return M.async_execute(cmd, project_root, env, function(exit_code)
    if exit_code == 0 then
      if callback then
        callback(exit_code)
      end
    else
      vim.notify("Failed to update GTAGS database", vim.log.levels.WARN)
      M.generate_full(project_root, cache_path, callback)
    end
  end)
end

function M.update_or_generate()
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

  if M.has_gtags_db(cache_path) then
    M.update_incremental(project_root, cache_path)
  else
    M.generate_full(project_root, cache_path)
  end
end

function M.deboundced_update_or_generate()
  if M.state.update_timer then
    vim.fn.timer_stop(M.state.update_timer)
  end
  M.state.update_timer = vim.fn.timer_start(500, function()
    M.state.update_timer = nil
    M.update_or_generate()
  end)
end

function M.regenerate()
  local project_root = M.get_project_root()
  local cache_path = M.get_cache_path(project_root)
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
    callback = function()
      vim.defer_fn(function()
        M.deboundced_update_or_generate()
      end, 100)
    end,
  })
end

function M.setup_commands()
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
  M.state.steuped = true
  M.setup_autocmds()
  M.setup_commands()
end

return M
