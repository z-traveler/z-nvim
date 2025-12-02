return {
  "milanglacier/minuet-ai.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("minuet").setup({
      provider = "claude",
      throttle = 300,
      debounce = 200,
      n_completions = 2,
    })
  end,
}
