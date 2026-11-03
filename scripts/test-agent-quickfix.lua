local directory = vim.fn.tempname()
vim.fn.mkdir(directory, "p", 448)
local function check()
  require("lazy").load({ plugins = { "nvim-bqf" } })
  local plugin = assert(require("lazy.core.config").plugins["omni-prompt-editor"])
  local source = vim.env.OMNI_HOOKS_TEST_SOURCE or plugin.dir
  local module = dofile(source .. "/modules/nvim/pi/lua/omni-pi-nvim/init.lua")
  local first, second = directory .. "/first.lua", directory .. "/second.lua"
  vim.fn.writefile({ "local a=1", "local b=2", "local c=3", "local d=4", "return a+b+c+d" }, first)
  vim.fn.writefile({ "local value=1", "return value" }, second)
  module.apply({ filename = first, lnum = 1, text = "write" }, "Turn 1: tree check", true)
  module.apply({ filename = second, lnum = 2, text = "edit" }, "Turn 1: tree check", false)
  module.apply({ filename = first, lnum = 3, text = "apply_patch" }, "Turn 1: tree check", false)
  local list = vim.fn.getqflist({ items = 1, context = 1 })
  assert(#list.items == 3, "tree lost real quickfix entries")
  assert(list.items[1].bufnr == list.items[2].bufnr, "same-file edits were not grouped")
  assert(list.context.omni_hooks_nvim.schema == 1, "agent ownership marker is missing")
  local win = vim.api.nvim_get_current_win()
  assert(vim.fn.getwininfo(win)[1].quickfix == 1, "agent list did not open")
  local ns = vim.api.nvim_get_namespaces().OmniNvimQuickfixTree
  assert(#vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {}) > 0, "tree colors and headers are missing")
  vim.api.nvim_win_set_cursor(win, { 1, 0 })
  vim.cmd("normal za")
  assert(vim.fn.foldclosed(1) == 1, "file group did not collapse with bqf enabled")
  module.apply({ filename = first, lnum = 5, text = "edit" }, "Turn 1: tree check", false)
  assert(vim.fn.foldclosed(1) == 1, "bqf refresh lost the collapsed file")
  vim.cmd("normal za")
  assert(vim.fn.foldclosed(1) == -1, "file group did not expand")
  vim.fn.setqflist({}, "a", { idx = 2 })
  vim.cmd("cc")
  assert(vim.fn.expand("%:t") == "first.lua" and vim.fn.line(".") == 3, "quickfix jump lost its source location")
  vim.fn.setqflist({}, " ", { title = "ordinary search", items = { { filename = second, lnum = 1, text = "match" } } })
  vim.cmd("copen")
  assert(
    vim.wait(1000, function()
      return #vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {}) == 0
    end),
    "ordinary search retained agent tree decoration"
  )
  assert(
    vim.fn.getqflist({ quickfixtextfunc = 1 }).quickfixtextfunc == "",
    "ordinary search retained the agent formatter"
  )
end

local ok, failure = xpcall(check, debug.traceback)
vim.fn.delete(directory, "rf")
if ok then
  print("agent quickfix tree, bqf folds, native jumps and ordinary-list isolation verified")
  vim.cmd("cquit! 0")
else
  vim.api.nvim_err_writeln(failure)
  vim.cmd("cquit! 1")
end
