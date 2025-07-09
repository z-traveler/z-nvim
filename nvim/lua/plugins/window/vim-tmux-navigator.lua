return {
  "christoomey/vim-tmux-navigator",
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
    vim.g.tmux_navigator_disable_when_zoomed = 1
  end,
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<A-h>", "<cmd>TmuxNavigateLeft<cr>", mode = "n", desc = "Go To Left Window", noremap = true, silent = true },
    { "<A-j>", "<cmd>TmuxNavigateDown<cr>", mode = "n", desc = "Go To Lower Window", noremap = true, silent = true },
    { "<A-k>", "<cmd>TmuxNavigateUp<cr>", mode = "n", desc = "Go To Upper Window", noremap = true, silent = true },
    { "<A-l>", "<cmd>TmuxNavigateRight<cr>", mode = "n", desc = "Go to Right Window", noremap = true, silent = true },
  },
}
