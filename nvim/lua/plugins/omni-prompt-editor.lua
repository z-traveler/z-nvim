return {
  {
    "z-traveler/omni-hooks",
    name = "omni-prompt-editor",
    lazy = false,
    config = function(plugin)
      vim.opt.runtimepath:prepend(plugin.dir .. "/modules/prompt-editor/nvim")
      require("omni-prompt-editor").setup()
    end,
  },
}
