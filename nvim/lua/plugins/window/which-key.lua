return {
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.delay = 666
      local spec = opts.spec or {}
      if spec and spec[1] then
        for i = #spec[1], 1, -1 do
          local item = spec[1][i]
          if type(item) == "table" and item[1] == "<leader>c" then
            table.remove(spec[1], i)
            break
          end
        end
      end
      opts.spec[1][#opts.spec[1] + 1] = { "<leader>l", group = "lsp", icon = { icon = "󱚡", color = "cyan" } }
      opts.spec[1][#opts.spec[1] + 1] = { "<leader>v", group = "version", icon = { icon = "", color = "cyan" } }
      opts.spec[1][#opts.spec[1] + 1] = { "<leader>p", group = "put", icon = { icon = "", color = "cyan" } }
      opts.spec[1][#opts.spec[1] + 1] = { "<leader>c", group = "custom", icon = { icon = "", color = "cyan" } }
    end,
  },
}
