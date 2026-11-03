return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    enabled = false,
  },
  {
    "OXY2DEV/markview.nvim",
    commit = "ecc5a8867daa1856f8bcc5fdbceca8f5a5ce5f5d",
    lazy = false,
    opts = {
      markdown = {
        list_items = { shift_width = 1 },
      },
    },
    keys = {
      { "<leader>um", "<cmd>Markview toggle<cr>", ft = "markdown", desc = "Render Markdown" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local m_opts = {
        servers = {
          marksman = {},
        },
      }
      return vim.tbl_deep_extend("force", opts or {}, m_opts)
    end,
  },
}
