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

return M
