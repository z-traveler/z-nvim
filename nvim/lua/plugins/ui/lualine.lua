local sources = require("config.ui.lualine").sources

return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local m_opts = {
        options = {
          theme = "auto",
          icons_enabled = true,
          globalstatus = false,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = { statusline = { "dashboard", "alpha", "ministarter", "snacks_dashboard" } },
          refresh = {
            statusline = 666,
            tabline = 666,
            winbar = 666,
            refresh_time = 66, -- ~15fps
            events = {
              "WinEnter",
              "BufEnter",
              "BufWritePost",
              "SessionLoadPost",
              "FileChangedShellPost",
              "VimResized",
              "Filetype",
              "ModeChanged",
              -- OPTIM: 性能优化, 等待自动更新, 而不是事件刷新
              -- "CursorMoved",
              -- "CursorMovedI",
            },
          },
        },
        sections = {
          lualine_a = {
            sources.mode,
          },
          lualine_b = {
            sources.branch,
            sources.root_dir(),
            sources.filetype,
            sources.pretty_path,
          },
          lualine_c = {
            -- sources.symbol(),  -- 有些华而不实
            sources.diff,
          },
          lualine_x = {
            sources.diagnostics,
            sources.scrollbar,
            sources.noice_command,
            sources.dap,
            sources.treesitter,
            sources.lsp_clients,
          },
          lualine_y = {
            sources.noice_mode,
            sources.encoding,
          },
          lualine_z = {
            sources.slogan,
          },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {
            sources.filename,
          },
          lualine_c = {
            sources.diff,
          },
          lualine_x = {},
          lualine_y = {},
          lualine_z = {},
        },
        extensions = { "neo-tree", "lazy", "fzf" },
      }
      return m_opts
    end,
  },
}
