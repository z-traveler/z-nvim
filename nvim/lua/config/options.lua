-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- 时间设置
vim.opt.updatetime = 666
vim.opt.timeoutlen = 666
vim.g.cursorhold_updatetime = 666

-- ui
vim.o.winborder = "rounded"
vim.opt.termguicolors = true
vim.opt.cmdheight = 1
vim.opt.numberwidth = 4
vim.opt.signcolumn = "yes:2"
vim.opt.colorcolumn = "99999" -- 修复indentline显示问题
vim.opt.showmode = false -- 不显示INSERT等模式提示

-- 输入
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
vim.opt.showmatch = false
vim.g.loaded_matchparen = 1
vim.g.matchparen_timeout = 10
vim.g.matchparen_insert_timeout = 10
-- 禁用自动注释延续
vim.opt.formatoptions:remove({ "c", "r", "o" })
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- 文件设置
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.autowrite = false
vim.opt.autoread = true
vim.opt.fileencodings = { "utf-8", "gbk" }
vim.opt.encoding = "utf-8"
