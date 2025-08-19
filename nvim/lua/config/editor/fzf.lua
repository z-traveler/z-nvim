_G.exclude_dirs = {
  "*.pyc",
  "*.pyo",
  "*.so",
  "*.o",
}
function _G.add_exclude_dirs(dir)
  table.insert(_G.exclude_dirs, dir)
end

local M = {}

M.start_grep_inselected_dirs = function(dirs)
  local rg_globs = ""
  local cwd = vim.fn.getcwd() .. "/"
  for _, dir in ipairs(dirs) do
    local rel_dir
    if dir:find(cwd, 1, true) == 1 then
      rel_dir = dir:sub(#cwd + 1)
    else
      rel_dir = dir
    end
    if not dir:match("/$") then
      rel_dir = rel_dir .. "/"
    end
    rg_globs = rg_globs .. " -g '" .. rel_dir .. "**'"
  end
  require("fzf-lua").live_grep({
    prompt = "Rg in " .. rg_globs .. "❯ ",
    cmd = "rg --column --line-number --no-heading --color=always --smart-case --max-columns=4096 --trim"
      .. rg_globs
      .. " -e",
  })
end

function M.select_and_grep()
  require("fzf-lua").files({
    prompt = "Dirs❯ ",
    fd_opts = "--color=never --type d --hidden --follow --exclude .git",
    actions = {
      ["default"] = function(selected, opts)
        local paths = {}
        for i = 1, #selected do
          local file = require("fzf-lua.path").entry_to_file(selected[i], opts, opts.force_uri)
          table.insert(paths, file.path)
        end
        M.start_grep_inselected_dirs(paths)
      end,
    },
  })
end

function M.files_excluded()
  local fzf = require("fzf-lua")
  local config = fzf.config
  local fd_opts = config.defaults.files.fd_opts
  if _G.exclude_dirs then
    for _, dir in ipairs(_G.exclude_dirs) do
      fd_opts = fd_opts .. " --exclude '" .. dir .. "'"
    end
  end
  fzf.files({ fd_opts = fd_opts })
end

function M.rg_excluded(visual)
  local fzf = require("fzf-lua")
  local rg_globs = ""
  for _, dir in ipairs(_G.exclude_dirs) do
    if dir:match("/$") then
      rg_globs = rg_globs .. " -g '!" .. dir .. "**'"
    else
      rg_globs = rg_globs .. " -g '!" .. dir .. "'"
    end
  end

  local func = nil
  if visual then
    func = fzf.grep_visual
  else
    func = fzf.live_grep
  end

  func({
    cmd = "rg --column --line-number --no-heading --color=always --smart-case --max-columns=4096 --trim"
      .. rg_globs
      .. " -e",
  })
end

function M.live_grep(visual)
  local fzf = require("fzf-lua")

  local func = nil
  if visual then
    func = fzf.grep_visual
  else
    func = fzf.live_grep
  end

  func({
    cmd = "rg --column --line-number --no-heading --color=always --smart-case --max-columns=4096 --trim -e",
  })
end

function _G.cascade_grep()
  local fzf_lua = require("fzf-lua")

  -- 第一次搜索
  fzf_lua.live_grep({
    actions = {
      ["ctrl-q"] = {
        fn = function(selected)
          -- 将选中的行保存到临时文件
          local lines = {}
          for _, item in ipairs(selected) do
            table.insert(lines, item)
          end

          -- 对这些行进行二次搜索
          fzf_lua.fzf_exec(lines, {
            prompt = "2nd Search> ",
            actions = {
              ["default"] = function(sel)
                -- 处理最终选择的结果
                fzf_lua.actions.file_edit(sel)
              end,
            },
          })
        end,
        reload = false,
      },
    },
  })
end

function M.gtag_grep()
  local gtag = require("config.editor.gtag")
  local gtags_env = gtag.get_gtags_env()
  if not gtags_env then
    vim.notify("No gtags database found", vim.log.levels.WARN)
    return
  end

  local fzf = require("fzf-lua")
  local func = fzf.live_grep

  local env_str = ""
  for k, v in pairs(gtags_env) do
    env_str = env_str .. k .. "=" .. v .. " "
  end

  local base_cmd = env_str .. "global --color=always --result=grep -i"
  local ctx = string.format(" %d:%s", vim.fn.line("."), vim.fn.expand("%p"))
  local cword = vim.fn.expand("<cword>") or ""

  local query_params = {
    ["--from-here"] = { active = false, desc = "ctx", key = "ctrl-h" },
    ["-d"] = { active = false, desc = "def", key = "ctrl-d" },
    ["-r"] = { active = false, desc = "ref", key = "ctrl-r" },
  }

  if cword then
    query_params["--from-here"].active = true
  else
    query_params["-d"].active = true
  end

  local function build_cmd()
    for param, info in pairs(query_params) do
      if info.active then
        if param == "--from-here" then
          return base_cmd .. " " .. param .. ctx
        else
          return base_cmd .. " " .. param
        end
      end
    end
    return base_cmd
  end

  local function build_header()
    local status = {}
    local green = "\27[32m" -- 绿色
    local gray = "\27[90m" -- 灰色
    local reset = "\27[0m" -- 重置颜色

    local no_active = true
    for _, info in pairs(query_params) do
      if info.active then
        no_active = false
      end
    end
    if no_active then
      query_params["-d"].active = true
    end

    for _, info in pairs(query_params) do
      local indicator = info.active and "●" or "○"
      local color = info.active and green or gray
      table.insert(status, string.format("%s%s: %s %s%s", color, info.key, indicator, info.desc, reset))
    end
    return table.concat(status, " | ")
  end

  local function build_actions()
    local actions = {}
    for param, info in pairs(query_params) do
      actions[info.key] = { fn = toggle_param(param), reload = true }
    end
    return actions
  end

  function toggle_param(target_param)
    return function(opts)
      if query_params[target_param].active then
        query_params[target_param].active = false
      else
        for param, info in pairs(query_params) do
          info.active = (param == target_param)
        end
      end

      -- 重新启动 fzf
      func({
        resume = true,
        cmd = build_cmd(),
        actions = build_actions(),
        prompt = "gtag> ",
        header = build_header(),
        fn_transform = function(x)
          return x:gsub("%s+", " ")
        end,
      })
    end
  end

  func({
    cmd = build_cmd(),
    query = cword,
    actions = build_actions(),
    prompt = "gtag> ",
    header = build_header(),
    fn_transform = function(x)
      return x:gsub("%s+", " ")
    end,
  })
end

return M
