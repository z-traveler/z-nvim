return {
  "folke/snacks.nvim",
  opts = { explorer = {} },
  keys = {
    {
      "<A-e>",
      function()
        Snacks.explorer({ cwd = LazyVim.root() })
      end,
      desc = "Explorer Snacks (root dir)",
    },
    {
      "<A-E>",
      function()
        Snacks.explorer()
      end,
      desc = "Explorer Snacks (cwd)",
    },
    -- disable default
    { "<leader>fE", false },
    { "<leader>fe", false },
    { "<leader>e", false },
    { "<leader>E", false },
  },
}
