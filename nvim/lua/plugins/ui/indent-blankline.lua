return {
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = function(_, opts)
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "IndentBlanklineIndent1", { fg = "#58292D" })
        vim.api.nvim_set_hl(0, "IndentBlanklineIndent2", { fg = "#5A4B2F" })
        vim.api.nvim_set_hl(0, "IndentBlanklineIndent3", { fg = "#3B4C2E" })
        vim.api.nvim_set_hl(0, "IndentBlanklineIndent4", { fg = "#21474C" })
        vim.api.nvim_set_hl(0, "IndentBlanklineIndent5", { fg = "#25455F" })
        vim.api.nvim_set_hl(0, "IndentBlanklineIndent6", { fg = "#4E2F57" })
      end)
      local highlight = {
        "IndentBlanklineIndent1",
        "IndentBlanklineIndent2",
        "IndentBlanklineIndent3",
        "IndentBlanklineIndent4",
        "IndentBlanklineIndent5",
        "IndentBlanklineIndent6",
      }
      local m_opts = {
        scope = {
          enabled = false,
        },
        indent = {
          char = "│",
          highlight = highlight,
        },
      }
      return vim.tbl_deep_extend("force", opts or {}, m_opts)
    end,
  },
}
