return {
  {
    "snacks.nvim",
    opts = function(_, opts)
      if not opts or not opts.terminal or not opts.terminal.win or not opts.terminal.win.keys then
        return opts
      end
      local keys = opts.terminal.win.keys
      local key_mapping = {
        ["<C-h>"] = "<A-h>",
        ["<C-j>"] = "<A-j>",
        ["<C-k>"] = "<A-k>",
        ["<C-l>"] = "<A-l>",
      }
      for _, key_config in pairs(keys) do
        if type(key_config) == "table" and key_config[1] then
          local old_key = key_config[1]
          if key_mapping[old_key] then
            key_config[1] = key_mapping[old_key]
          end
        end
      end
    end,
  },
}
