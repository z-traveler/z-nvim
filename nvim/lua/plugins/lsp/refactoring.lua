return {
  {
    "ThePrimeagen/refactoring.nvim",
    lazy = false,
    keys = {
      { "<leader>rs", false, mode = { "n", "v" } },
      { "<leader>rf", false, mode = { "n", "v" } },
      { "<leader>rx", false, mode = { "n", "v" } },
      { "<leader>rf", false, mode = { "n", "v" } },
      { "<leader>rF", false, mode = { "n", "v" } },
      { "<leader>rb", false, mode = { "n", "v" } },
      { "<leader>ri", ":Refactor inline_var", mode = { "n", "x" }, desc = "Inline variable" },
      { "<leader>rI", ":Refactor inline_func", mode = { "n" }, desc = "Inline function" },
      { "<leader>re", ":Refactor extract ", mode = { "x" }, desc = "Extract" },
      { "<leader>rv", ":Refactor extract_var ", mode = { "x" }, desc = "Extract variable" },
    },
  },
}
