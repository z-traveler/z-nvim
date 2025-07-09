local ui = require("config.ui")
local colors = ui.colors

return {
  {
    "folke/flash.nvim",
    opts = function(_, opts)
      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "LazyLoad",
        callback = function(event)
          ui.update_hl("FlashMatch", { fg = colors.dim_yellow, bg = colors.color_bg, bold = true })
          ui.update_hl("FlashCurrent", { fg = colors.dim_yellow, bg = colors.color_bg, bold = true })
          ui.update_hl("FlashLabel", { fg = colors.light_cyan, bold = true, italic = true, underline = true })
        end,
        once = true,
      })
      return opts
    end,
    keys = {
      { "r", false },
      { "R", false },
      { "<c-s>", false },
    },
  },
}
