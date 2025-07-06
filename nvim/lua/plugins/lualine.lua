local ui_cfg = require("config.ui")
local lualine_sources = ui_cfg.lualine_sources

return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function()
      local opts = {
        options = {
          theme = "auto",
          icons_enabled = true,
          globalstatus = false,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
        },
        sections = {
          lualine_a = {
            lualine_sources.mode,
          },
          lualine_b = {
            lualine_sources.branch,
            lualine_sources.root_dir(),
            lualine_sources.filetype,
            lualine_sources.pretty_path,
          },
          lualine_c = {
            lualine_sources.symbol(),
            lualine_sources.diff,
          },
          lualine_x = {
            lualine_sources.diagnostics,
            lualine_sources.scrollbar,
            lualine_sources.noice_command,
            lualine_sources.dap,
            lualine_sources.treesitter,
            lualine_sources.lsp_clients,
          },
          lualine_y = {
            lualine_sources.noice_mode,
            lualine_sources.lazy_status,
            lualine_sources.encoding,
          },
          lualine_z = {
            lualine_sources.slogan,
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {
            lualine_sources.filename,
          },
          lualine_c = {
            lualine_sources.diff,
          },
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
        extensions = { "neo-tree", "lazy", "fzf" },
      }
      return opts
    end,
  },
}
