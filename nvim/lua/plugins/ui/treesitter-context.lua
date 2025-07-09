local ui = require("config.ui")
local colors = ui.colors

return {
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = function(_, opts)
      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "LazyLoad",
        callback = function(event)
          ui.update_hl("TreesitterContextBottom", { bg = colors.light_bg })
          ui.update_hl("TreesitterContextLineNumberBottom", { underline = true })
        end,
        once = true,
      })
      local m_opts = {
        multiwindow = true,
      }
      return vim.tbl_deep_extend("force", opts or {}, m_opts)
    end,
  },
}
