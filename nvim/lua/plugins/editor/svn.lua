return {
  {
    "mhinz/vim-signify",
    init = function()
      vim.g.signify_sign_add = "▎"
      vim.g.signify_sign_change = "▎"
      vim.g.signify_sign_delete = ""
      vim.g.signify_priority = 1
    end,
  },
}
