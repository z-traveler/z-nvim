return {
  {
    "z-traveler/omni-hooks",
    name = "omni-prompt-editor",
    commit = "46a9e6880f2e8fe95aadd7aa65fb7c0277d2ae28",
    lazy = false,
    config = function(plugin)
      vim.opt.runtimepath:prepend(plugin.dir .. "/modules/prompt-editor/nvim")
      require("omni-prompt-editor").setup()
    end,
  },
}
