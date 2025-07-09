local ui = require("config.ui")
local update_hl = ui.update_hl
local colors = ui.colors

local overwrite_gruvbox_hl = function()
  if vim.g.colors_name ~= "gruvbox-material" then
    return
  end

  update_hl("CursorLine", { bg = colors.light_bg })
  update_hl("CurrentWord", { bg = colors.dark_fg })
  update_hl("Normal", { bg = colors.none })
  update_hl("NormalNC", { bg = colors.none })
  update_hl("NormalFloat", { bg = colors.none, fg = colors.cyan })
  update_hl("FloatBorder", { bg = colors.none, fg = colors.cyan })
  update_hl("SignColumn", { bg = colors.none })
  update_hl("MsgArea", { bg = colors.none })
  update_hl("EndOfBuffer", { bg = colors.none })

  update_hl("Pmenu", { bg = colors.none, fg = colors.cyan }) -- 补全菜单
  update_hl("PmenuSel", { fg = colors.orange, bg = colors.dark_fg }) -- 补全菜单选中项
  update_hl("PmenuSbar", { bg = colors.none }) -- 滚动条拖拽块
  update_hl("PmenuThumb", { bg = colors.dark_fg }) -- 滚动条背景
  update_hl("PmenuExtra", { bg = colors.none, fg = colors.dim_white, bold = false }) -- 补全菜单的标签描述
  update_hl("LspSigActiveParameter", { bg = colors.color_bg, fg = colors.light_blue, link = nil })
  update_hl("LspSignatureActiveParameter", { bg = colors.color_bg, fg = colors.light_green, link = nil })
  update_hl("SnippetTabstop", { bg = colors.color_bg, fg = colors.cyan, link = nil })
end

return {
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", enabled = false },
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.gruvbox_material_better_performance = 1
      vim.g.gruvbox_material_transparent_background = 2
      vim.g.gruvbox_material_inlay_hints_background = 1
      vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
      vim.api.nvim_create_autocmd({ "ColorScheme" }, {
        pattern = "gruvbox-material",
        callback = function()
          overwrite_gruvbox_hl()
        end,
      })

      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "LazyVimAutocmds",
        callback = function()
          overwrite_gruvbox_hl()
        end,
        once = true,
      })
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox-material",
    },
  },
}
