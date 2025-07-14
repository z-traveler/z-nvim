-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local inlay_group = vim.api.nvim_create_augroup("inlay_hints_toggle", { clear = true })
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
  group = inlay_group,
  callback = function()
    vim.lsp.inlay_hint.enable(false)
  end,
})
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  group = inlay_group,
  callback = function()
    vim.lsp.inlay_hint.enable(true)
  end,
})
