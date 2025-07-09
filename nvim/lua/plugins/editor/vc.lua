local cft = require("config.editor.version")

return {
  {
    "juneedahamed/vc.vim",
    keys = {
      -- stylua: ignore
      { "<leader>vR", function() cft.revert_buffer() end, desc = "Revert Buffer"},
      { "<leader>vr", ":w<cr>:SignifyHunkUndo<cr>", desc = "Revert Hunk" },
      { "<leader>vd", "<cmd>SignifyHunkDiff<cr>", desc = "Diff Hunk" },
      { "<leader>vc", ":VCStatus<CR>M ", desc = "Commit Change" },
      { "<leader>vl", "<cmd>VCLog<cr>", desc = "Commit Log" },
      { "]v", "<plug>(signify-next-hunk)", desc = "Next Hunk" },
      { "[v", "<plug>(signify-prev-hunk)", desc = "Prev Hunk" },
    },
  },
}
