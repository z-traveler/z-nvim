local colors = require("config.ui").colors
local update_hl = require("config.ui").update_hl

local function apply_highlights()
  update_hl("BlinkPairsRed", { fg = colors.red })
  update_hl("BlinkPairsYellow", { fg = colors.yellow })
  update_hl("BlinkPairsBlue", { fg = colors.blue })
  update_hl("BlinkPairsOrange", { fg = colors.orange })
  update_hl("BlinkPairsGreen", { fg = colors.green })
  update_hl("BlinkPairsViolet", { fg = colors.violet })
  update_hl("BlinkPairsCyan", { fg = colors.cyan })
  update_hl("MatchParen", { bg = colors.dark_fg, fg = colors.light_green })
end

return {
  { "nvim-mini/mini.pairs", enabled = true },
  {
    "saghen/blink.pairs",
    version = "*",
    dependencies = "saghen/blink.download",
    opts = function(_, opts)
      apply_highlights()
      vim.api.nvim_create_autocmd({ "ColorScheme" }, {
        callback = apply_highlights,
      })
      local m_opts = {
        mappings = {
          enabled = false,
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
