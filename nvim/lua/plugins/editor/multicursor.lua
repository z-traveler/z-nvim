return {
  {
    "jake-stewart/multicursor.nvim",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()
      mc.addKeymapLayer(function(layerSet)
        -- Enable and clear cursors using escape.
        layerSet("n", "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)
    end,
    keys = {
      -- stylua: ignore
      { "<A-]>", function() require("multicursor-nvim").matchAddCursor(1) end, "Multiple Cursor"},
      -- stylua: ignore
      { "<A-[>", function() require("multicursor-nvim").matchSkipCursor(-1) end, "Multiple Cursor",
      },
    },
  },
}
