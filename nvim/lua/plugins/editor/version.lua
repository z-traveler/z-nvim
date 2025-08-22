local cft = require("config.editor.version")

return {
  {
    "mhinz/vim-signify",
    event = "VeryLazy",
    init = function()
      vim.g.signify_sign_add = "▎"
      vim.g.signify_sign_change = "▎"
      vim.g.signify_sign_delete = ""
      vim.g.signify_priority = 1000
      -- vim.g.signify_vcs_cmds_diffmode = {
      --   git = 'git show HEAD:./%f | tr -d "\r"',
      --   svn = 'svn cat %f | tr -d "\r"',
      -- } -- NOTE: 可以解决^M
    end,
    keys = {
      { "]v", "<plug>(signify-next-hunk)", desc = "Next Hunk" },
      { "[v", "<plug>(signify-prev-hunk)", desc = "Prev Hunk" },
      -- stylua: ignore start
      { "<leader>vR", function() cft.revert_buffer() end, desc = "Revert Buffer"},
      { "<leader>vr", function () cft.revert_hunk() end, desc = "Revert Hunk" },
      { "<leader>vd", function() cft.diff_hunk() end, desc = "Diff Hunk", },
      { "<leader>vD", function() cft.diff_buffer() end, desc = "Diff Buffer", },
      -- stylua: ignore end
    },
  },
  {
    "juneedahamed/vc.vim",
    keys = {
      { "<leader>vc", ":VCStatus<cr>M ", desc = "Commit Change" },
      -- stylua: ignore start
      { "<leader>vl", function() cft.log() end, desc = "Buffer Log" },
      { "<leader>vb", function () cft.blame_buffer() end, desc = "Buffer Blame" },
      -- stylua: ignore end
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(bufnr)
        -- NOTE: 覆盖Lazyvim默认键位
      end,
    },
  },
}
