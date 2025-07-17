return {
  {
    "folke/snacks.nvim",
    opts = function()
      Snacks.toggle.profiler():map("<F1>")
    end,
  }
}
