return {
  {
    "snacks.nvim",
    opts = function(_, opts)
      if not opts or not opts.terminal or not opts.terminal.win or not opts.terminal.win.keys then
        return opts
      end
      local keys = opts.terminal.win.keys
      -- Alt-h/j/k/l 由 vim-tmux-navigator 全局接管，这里只移除 LazyVim 默认的 Ctrl 导航。
      local ctrl_navigation_keys = {
        ["<C-h>"] = true,
        ["<C-j>"] = true,
        ["<C-k>"] = true,
        ["<C-l>"] = true,
      }
      for name, key_config in pairs(keys) do
        if type(key_config) == "table" and ctrl_navigation_keys[key_config[1]] then
          keys[name] = nil
        end
      end
    end,
  },
}
