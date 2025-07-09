local buffer = require("config.editor.buffer")

return {
  "akinsho/bufferline.nvim",
  keys = {
    { "<leader>bp", false },
    { "<leader>bP", false },
    { "<leader>br", false },
    { "<leader>bl", false },
    { "[B", false },
    { "]B", false },
    { "J", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "K", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
    { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    -- stylua: ignore
    { "q", function() buffer.buf_kill("bd", 0, true) end, desc = "Close Buffer", silent = true },
    -- stylua: ignore
    { "<leader>bs", function() Snacks.scratch.select()  end, desc = "Select Scratch Buffer" },
    { "<leader>bS", "<cmd>BufferLineSortByDirectory<cr>", desc = "Sort Buffer By Directory" },
    -- stylua: ignore
    { "<leader>bd", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
  },
  opts = {
    options = {
      numbers = "none",
      -- stylua: ignore
      close_command = function() buffer.buf_kill("bd", 0, true) end,
      diagnostics = false,
      always_show_bufferline = true,
      show_buffer_close_icons = false,
      enforce_regular_tabs = true,
      separator_style = "thin",
      sort_by = "relative_directory'",
      indicator = {
        style = "underline",
      },
    },
    highlights = {
      buffer_selected = {
        underline = true,
      },
    },
  },
}
