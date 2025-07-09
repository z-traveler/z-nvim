local cfg = require("config.window")

return {
  {
    "rmagatti/goto-preview",
    opts = {
      width = 120,
      height = 25,
      opacity = 10,
      post_open_hook = function(buf, _)
        vim.keymap.set("n", "q", function()
          local win_type = vim.fn.win_gettype()
          if win_type == "popup" or win_type == "preview" then
            return "ZZ"
          else
            return "q"
          end
        end, { buffer = buf, expr = true, silent = true, remap = true })
      end,
    },
    keys = {
      { "gl", "<cmd>lua require('goto-preview').goto_preview_definition()<cr>", desc = "Preview Define In Float" },
      { "gq", "<cmd>lua require('goto-preview').close_all_win()<cr>", desc = "Close All Preview Win" },
      -- stylua: ignore
      { "<leader>wL", function () cfg.exchange_to_right() end, desc = "Move To Left Win"} ,
      -- stylua: ignore
      { "<leader>wH", function () cfg.exchange_to_left() end, desc = "Move To Left Win"} ,
    },
  },
}
