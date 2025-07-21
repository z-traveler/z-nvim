return {
  {
    "lukas-reineke/indent-blankline.nvim",
    enabled = false, -- 有点卡
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
          tab_char = "│",
          highlight = highlight,
        },
      }
      return vim.tbl_deep_extend("force", opts or {}, m_opts)
    end,
  },
  {
    "snacks.nvim",
    opts = function(_, opts)
      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "LazyLoad",
        callback = function()
          vim.api.nvim_set_hl(0, "SnacksIndent1", { fg = "#58292D" })
          vim.api.nvim_set_hl(0, "SnacksIndent2", { fg = "#5A4B2F" })
          vim.api.nvim_set_hl(0, "SnacksIndent3", { fg = "#3B4C2E" })
          vim.api.nvim_set_hl(0, "SnacksIndent4", { fg = "#21474C" })
          vim.api.nvim_set_hl(0, "SnacksIndent5", { fg = "#25455F" })
          vim.api.nvim_set_hl(0, "SnacksIndent6", { fg = "#4E2F57" })
        end,
        once = true,
      })
      local m_opts = {
        indent = {
          indent = {
            hl = {
              "SnacksIndent1",
              "SnacksIndent2",
              "SnacksIndent3",
              "SnacksIndent4",
              "SnacksIndent5",
              "SnacksIndent6",
            },
          },
          animation = {
            enabled = false,
          },
          scope = {
            enabled = false,
          },
        },
      }
      return vim.tbl_deep_extend("force", opts or {}, m_opts)
    end,
  },
  {
    "nmac427/guess-indent.nvim",
  },
}
