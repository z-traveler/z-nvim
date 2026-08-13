return {
  {
    "folke/trouble.nvim",
    config = function(_, opts)
      require("trouble").setup(opts)
      local main = require("trouble.view.main")
      local valid = main._valid
      main._valid = function(win, buf)
        if
          win
          and buf
          and vim.api.nvim_win_is_valid(win)
          and vim.api.nvim_buf_is_valid(buf)
          and vim.api.nvim_win_get_buf(win) == buf
          and vim.b[buf].omni_prompt_answer
        then
          return true
        end
        return valid(win, buf)
      end
    end,
    keys = {
      { "<leader>xq", false },
      { "<leader>xx", false },
      { "<leader>xX", false },
      { "<leader>cs", false },
      { "<leader>cS", false },
      { "<leader>xL", false },
      { "<leader>xl", false },
      { "<leader>xQ", false },
      { "<A-s>", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
    },
  },
}
