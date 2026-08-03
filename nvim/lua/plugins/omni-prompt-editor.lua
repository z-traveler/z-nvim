return {
  {
    "z-traveler/omni-hooks",
    name = "omni-prompt-editor",
    commit = "bd282d9832d8e079c240361292815b27b8bbc513",
    lazy = false,
    config = function(plugin)
      vim.opt.runtimepath:prepend(plugin.dir .. "/modules/prompt-editor/nvim")
      require("omni-prompt-editor").setup()
    end,
  },
}
