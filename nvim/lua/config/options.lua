-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazy = true

-- for profile
vim.opt.updatetime = 666
vim.opt.timeoutlen = 666
vim.g.cursorhold_updatetime = 666
vim.g.matchparen_timeout = 10
vim.g.matchparen_insert_timeout = 10
vim.g.loaded_matchparen = 1

---- ui
vim.o.winborder = "rounded"
vim.opt.showmatch = false
vim.opt.termguicolors = true
vim.opt.cmdheight = 1
vim.opt.numberwidth = 4
vim.opt.signcolumn = "yes:2"
vim.opt.colorcolumn = "99999" -- 修复indentline显示问题
vim.opt.showmode = false -- 不显示INSERT等模式提示
-- char
vim.opt.list = false
vim.opt.listchars = {
  tab = '→ ',
  space = '·',
  trail = '•',
  extends = '❯',
  precedes = '❮',
  nbsp = '×',
  eol = '¬'
} -- 调试不可见符号时打开list, 关闭indent-blank
-- line
vim.opt.relativenumber = false
vim.opt.cursorline = true
vim.opt.wrap = true
vim.opt.linespace = 8
vim.opt.scrolloff = 9
vim.opt.sidescrolloff = 9
-- indent
vim.opt.expandtab = true
vim.opt.smartindent = false
vim.opt.autoindent = false
-- animations
vim.g.snacks_animate = false

---- window
vim.opt.splitbelow = false
vim.opt.splitright = false
vim.opt.winfixwidth = true

---- buffer
vim.opt.hidden = true
vim.opt.switchbuf = "usetab,uselast"

-- input
vim.opt.mouse = ""
vim.opt.clipboard = "unnamedplus"
-- WSL剪贴板特殊配置
if vim.fn.has("wsl") == 1 then
  vim.g.clipboard = {
    name = "WslClipboard",
    copy = {
      ["+"] = "clip.exe",
      ["*"] = "clip.exe",
    },
    paste = {
      ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = 0,
  }
end

-- 括号, 禁用匹配括号高亮（性能优化）
-- 禁用自动注释延续
vim.opt.formatoptions:remove({ "c", "r", "o" })
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

---- file
vim.opt.fileencodings = { "utf-8", "gbk" }
vim.opt.encoding = "utf-8"
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.autowrite = false
vim.opt.autoread = true
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath("cache") .. "/undo"

--- search
vim.g.lazyvim_picker = "fzf"
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrapscan = false

---- lsp
-- formatting
vim.g.autoformat = false
-- spell
vim.opt_local.spell = true
vim.cmd [[
    iabbrev adn and
    iabbrev calss class
    iabbrev sefl self
    iabbrev NOne None
]]

require("config.editor.fzf")
require("config.window.terminal")
if vim.fn.filereadable(".vimrc.local.lua") then
  pcall(dofile, ".vimrc.local.lua")
end
