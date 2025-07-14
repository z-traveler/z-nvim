return {
  {
    "Mythos-404/xmake.nvim",
    lazy = true,
    event = "VeryLazy",
    opts = {
      on_save = {
        lsp_compile_commands = {
          enable = true,
        },
        notify = {
          refresh_rate_ms = 50,
        },
      },
    },
    ft = { "lua" },
    config = true,
  },
}
