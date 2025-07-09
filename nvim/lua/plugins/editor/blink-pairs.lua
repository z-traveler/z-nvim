local colors = require("config.ui").colors
local update_hl = require("config.ui").update_hl

return {
  { "echasnovski/mini.pairs", enabled = false },
  {
    "saghen/blink.pairs",
    build = "cargo build --release",
    opts = function(_, opts)
      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "LazyLoad",
        callback = function()
          update_hl("BlinkPairsRed", { fg = colors.red })
          update_hl("BlinkPairsYellow", { fg = colors.yellow })
          update_hl("BlinkPairsBlue", { fg = colors.blue })
          update_hl("BlinkPairsOrange", { fg = colors.orange })
          update_hl("BlinkPairsGreen", { fg = colors.green })
          update_hl("BlinkPairsViolet", { fg = colors.violet })
          update_hl("BlinkPairsCyan", { fg = colors.cyan })
          update_hl("MatchParen", { bg = colors.dark_fg, fg = colors.light_green })
        end,
        once = true,
      })
      local m_opts = {
        mappings = {
          enabled = true,
          disabled_filetypes = {},
          pairs = {},
        },
        highlights = {
          enabled = true,
          groups = {
            "BlinkPairsRed",
            "BlinkPairsYellow",
            "BlinkPairsBlue",
            "BlinkPairsOrange",
            "BlinkPairsGreen",
            "BlinkPairsViolet",
            "BlinkPairsCyan",
          },
          unmatched_group = "BlinkPairsUnmatched",
          matchparen = {
            enabled = true,
            group = "MatchParen",
          },
        },
      }
      return vim.tbl_deep_extend("force", opts or {}, m_opts)
    end,
  },
}
