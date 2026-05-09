local ui = require("config.ui")
local colors = ui.colors

return {
  {
    "folke/flash.nvim",
    opts = function(_, opts)
      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "LazyLoad",
        callback = function(event)
          ui.update_hl("FlashMatch", { fg = colors.cyan, underline = true })
          ui.update_hl("FlashCurrent", { fg = colors.orange, bg = colors.dark_fg, bold = true })
          ui.update_hl("FlashLabel", { fg = colors.color_bg, bg = colors.yellow, bold = true })
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
