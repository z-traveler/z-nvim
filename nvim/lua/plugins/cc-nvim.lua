return {
  {
    dir = vim.fn.expand("~/.local/share/cc-nvim"),
    name = "cc-nvim",
    lazy = false,
    cond = function()
      return vim.fn.isdirectory(vim.fn.expand("~/.local/share/cc-nvim/lua")) == 1
    end,
    config = true,
  },
}
