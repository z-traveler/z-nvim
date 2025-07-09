local bqf_cfg = require("config.window.bqf")

return {
  {
    "kevinhwang91/nvim-bqf",
    event = "VeryLazy",
    keys = {
      -- stylua: ignore
      { "<A-q>", function() bqf_cfg.toggle_quickfix() end, desc = "Toggle Loclist "},
      -- stylua: ignore
      { "<A-o>", function() bqf_cfg.toggle_loclist() end, desc = "Toggle Loclist "},
      { "]q", "<cmd>cnext<cr>", desc = "Next Item" },
      { "[q", "<cmd>cprev<cr>", desc = "Prev Item" },
    },
  },
}
