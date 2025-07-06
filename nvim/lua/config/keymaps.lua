-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Insert模式 jk组合键映射到ESC
keymap.set("i", "jk", "<ESC>", opts)
keymap.set("i", "JK", "<ESC>", opts)
keymap.set("i", "Jk", "<ESC>", opts)
keymap.set("i", "KJ", "<ESC>", opts)
keymap.set("i", "Kj", "<ESC>", opts)

-- Visual模式下v键映射到ESC
keymap.set("v", "v", "<ESC>", opts)

-- Normal模式下leader+q映射到q
keymap.set("n", "<leader>q", "q", opts)
