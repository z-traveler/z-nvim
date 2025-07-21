return {
  "folke/snacks.nvim",
  opts = { explorer = {} },
  keys = {
    {
      "<A-e>",
      function()
        Snacks.explorer({
          cwd = LazyVim.root(),
          diagnostics = false,
          diagnostics_open = false,
          hidden = true,
          ignored = true,
        })
      end,
      desc = "Explorer Snacks (root dir)",
    },
    {
      "<A-E>",
      function()
        Snacks.explorer({
          diagnostics = false,
          diagnostics_open = false,
          hidden = true,
          ignored = true,
        })
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
