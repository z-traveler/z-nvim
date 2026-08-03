return {
  {
    "z-traveler/omni-hooks",
    name = "omni-prompt-editor",
    commit = "bd282d9832d8e079c240361292815b27b8bbc513",
    lazy = false,
    config = function(plugin)
      vim.opt.runtimepath:prepend(plugin.dir .. "/modules/prompt-editor/nvim")
      -- 避免旧的 site module 覆盖 lazy.nvim 固定的版本
      local module = dofile(plugin.dir .. "/modules/prompt-editor/nvim/lua/omni-prompt-editor/init.lua")
      package.loaded["omni-prompt-editor"] = module
      module.setup()
    end,
  },
}
