-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
local del = vim.keymap.del

---- operator
map("i", "jk", "<ESC>", { desc = "Leave Insert", noremap = true, silent = true })
map("i", "Jk", "<ESC>", { desc = "Leave Insert", noremap = true, silent = true })
map("i", "JK", "<ESC>", { desc = "Leave Insert", noremap = true, silent = true })
map("i", "KJ", "<ESC>", { desc = "Leave Insert", noremap = true, silent = true })
map("i", "Kj", "<ESC>", { desc = "Leave Insert", noremap = true, silent = true })
map("v", "v", "<ESC>", { desc = "Leave Visual", noremap = true, silent = true })
map("t", "<esc>", "<C-\\><C-n>", { desc = "Leave Terminal", noremap = true, silent = true })
map("t", "<jk>", "<C-\\><C-n>", { desc = "Leave Terminal", noremap = true, silent = true })
del("v", "<A-j>")
del("v", "<A-k>")
-- last
map("n", "`", "'", { desc = "", noremap = true, silent = true })
map("n", "'", "`", { desc = "", noremap = true, silent = true })
-- undo
map("n", "U", "<c-r>", { desc = "redo", noremap = true, silent = true })
-- marco
map("n", "<leader>q", "q", { desc = "Vim Macro", noremap = true })

---- ui
-- move window
-- see vim-tmux-navigator
map("n", "<A-w>", "<cmd>wincmd w<cr>", { desc = "Go to Window", noremap = true, silent = true })
map("n", "<leader>wv", "<cmd>vs<cr>", { desc = "Split Right", noremap = true, silent = true })
map("n", "<leader>ws", "<cmd>sp<cr>", { desc = "Split Down", noremap = true, silent = true })
-- resize window
map("n", "<A-up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height", silent = true })
map("n", "<A-down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height", silent = true })
map("n", "<A-left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width", silent = true })
map("n", "<A-right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width", silent = true })
-- close window
map("n", "Q", "ZZ", { desc = "Close Window", noremap = true, silent = true })
-- file explorer. see snack

---- quick_window
-- see bqf
del("n", "<leader>xl")
del("n", "<leader>xq")

--- buffer
-- see buffferline
del("n", "<leader>`")
del("n", "<leader>bb")
del("n", "<leader>bD")
del("n", "<leader>bo")

---- highlight
map("n", "<backspace>", function()
  LazyVim.cmp.actions.snippet_stop()
  vim.cmd("noh")
  vim.cmd("diffupdate")
  vim.cmd("redraw")
end, { desc = "Clear Highlight", silent = true })

---- input
map("i", "<C-j>", "<nop>", { desc = "Safe Set" })
map("i", "<C-l>", "<esc>la", { desc = "Move Left One Char" })
map("i", ";;", "<ESC>A;<ESC>o", { desc = "Move Line End Add ;" })
map("n", ";;", "A;<ESC>", { desc = "Move Line End Add ;" })
-- insert undo break-points
map("i", ",", ",<c-g>u", { desc = "Undo Break-points" })
map("i", ".", ".<c-g>u", { desc = "Undo Break-points" })
map("i", ";", ";<c-g>u", { desc = "Undo Break-points" })
-- better indenting
map("v", "<", "<gv", { desc = "Better Indent" })
map("v", ">", ">gv", { desc = "Beeter Indent" })

---- move
-- saner-behavior-of-n-and-n
-- better up/down, see lazyvim
-- line
map("n", "H", "^", { desc = "Go to First Non-Blank Character of Line", noremap = true, silent = true })
map("v", "H", "^", { desc = "Go to First Non-Blank Character of Line", noremap = true, silent = true })
map("n", "L", "$", { desc = "Go to Last Non-Blank Character of Line", noremap = true, silent = true })
map("v", "L", "$", { desc = "Go to Last Non-Blank Character of Line", noremap = true, silent = true })
map("n", "T", "J", { desc = "Connect Line", noremap = true, silent = true })

---- git
-- see lazyvim default
map("n", "<leader>vg", function() Snacks.lazygit( { cwd = LazyVim.root.git() }) end, { desc = "Lazygit (Root Dir)" })
del("n", "<leader>gg")
del("n", "<leader>gG")
del("n", "<leader>gf")
del("n", "<leader>gl")
del("n", "<leader>gL")
del("n", "<leader>gb")
del("n", "<leader>gB")
del("n", "<leader>gY")

---- terminal
del("n", "<leader>ft")
del("n", "<leader>fT")
del({ "n", "t" }, "<c-/>")
del({ "n", "t" }, "<c-_>")
map("n", "<A-t>", function()
  Snacks.terminal(nil, { cwd = LazyVim.root() })
end, { desc = "Terminal (Root Dir)" })
map("t", "<A-t>", "<cmd>close<cr>", { desc = "Hide Terminal" })

---- plugin
-- lazyvim
del("n", "<leader>l")
del("n", "<leader>S")
map("n", "<leader>P", "<cmd>Lazy<cr>", { desc = "Lazy" })
-- formatting
del({ "n", "v" }, "<leader>cf")
map({ "n", "v" }, "<leader>lf", function()
  LazyVim.format({ force = true })
end, { desc = "Format" })
-- diagnostic
del("n", "<leader>cd")
map("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Line Diagnostic" })
---- put
map("n", "<leader>py", require("config.editor.put").current_location, { desc = "Put Current Location" })
map("n", "<leader>pp", require("config.editor.put").locate, { desc = "Put Current Location" })
