local M = {}

local colors = {
  none = "none",
  color_bg = "#151d29",
  light_bg = "#16191f",
  fg = "#bbc2cf",
  dark_fg = "#2e314a",
  yellow = "#ecbe7b",
  cyan = "#008080",
  darkblue = "#081633",
  green = "#98be65",
  light_green = "#84a729",
  orange = "#fac03d",
  violet = "#a9a1e1",
  magenta = "#c678dd",
  purple = "#c678dd",
  blue = "#51afef",
  light_blue = "#8aabcc",
  white = "#d4e5ef",
  red = "#ec5f67",
}
M.colors = colors

M.overwrite_gruvbox_hl = function()
  if vim.g.colors_name ~= "gruvbox-material" then
    return
  end
  local update_hl = function(group_name, new)
    local current_hl = vim.api.nvim_get_hl(0, { name = group_name })
    vim.api.nvim_set_hl(0, group_name, vim.tbl_extend("force", current_hl, new))
  end
  update_hl("CursorLine", { bg = colors.light_bg })
  update_hl("CurrentWord", { bg = colors.dark_fg })
  update_hl("Normal", { bg = colors.none })
  update_hl("NormalNC", { bg = colors.none })
  update_hl("NormalFloat", { bg = colors.none })
  update_hl("FloatBorder", { bg = colors.none })
  update_hl("SignColumn", { bg = "none" })
  update_hl("MsgArea", { bg = "none" })
  update_hl("EndOfBuffer", { bg = "none" })

  update_hl("Pmenu", { bg = "none" }) -- 补全菜单
  update_hl("PmenuSel", { fg = colors.orange, bg = colors.dark_fg }) -- 补全菜单选中项
end

local conditions = {
  buffer_not_empty = function()
    return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
  end,
  hide_in_width = function()
    return vim.fn.winwidth(0) > 70
  end,
}

M.lualine_sources = {
  mode = {
    function()
      return " "
    end,
    padding = { left = 0, right = 0 },
    color = {},
    cond = nil,
  },

  branch = {
    "branch",
    icon = " ",
    color = { gui = "bold", bg = colors.color_bg },
    cond = conditions.hide_in_width,
  },

  treesitter = {
    function()
      local b = vim.api.nvim_get_current_buf()
      if next(vim.treesitter.highlighter.active[b]) then
        return ""
      end
      return ""
    end,
    color = { fg = colors.green },
    cond = conditions.hide_in_width,
  },

  lsp_clients = {
    function()
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      if #clients == 0 then
        return " "
      end

      local client_names = {}
      for _, client in pairs(clients) do
        if client.name ~= "null-ls" then
          table.insert(client_names, client.name)
        end
      end

      -- 获取格式化工具（如果使用conform.nvim）
      local conform_ok, conform = pcall(require, "conform")
      if conform_ok then
        local formatters = conform.list_formatters(0)
        for _, formatter in pairs(formatters) do
          table.insert(client_names, formatter.name)
        end
      end

      local unique_names = {}
      for _, name in pairs(client_names) do
        if not vim.tbl_contains(unique_names, name) then
          table.insert(unique_names, name)
        end
      end

      return "[" .. table.concat(unique_names, ", ") .. "]"
    end,
    color = { fg = colors.white },
    cond = conditions.hide_in_width,
  },

  encoding = {
    "o:fileencoding",
    fmt = string.upper,
    color = { bg = colors.none },
    cond = conditions.hide_in_width,
  },

  filetype = {
    "filetype",
    icon_only = true,
    padding = { left = 1, right = 0 },
    color = { bg = colors.none },
    cond = conditions.hide_in_width,
  },

  diagnostics = {
    "diagnostics",
    symbols = {
      error = LazyVim.config.icons.diagnostics.Error,
      warn = LazyVim.config.icons.diagnostics.Warn,
      info = LazyVim.config.icons.diagnostics.Info,
      hint = LazyVim.config.icons.diagnostics.Hint,
    },
    cond = conditions.hide_in_width,
  },

  ---@param opts? {cwd:false, subdirectory: true, parent: true, other: true, icon?:string}
  root_dir = function(opts)
    local ret = LazyVim.lualine.root_dir(opts)
    ret = vim.tbl_extend(
      "force",
      ret,
      { cond = conditions.hide_in_width, color = { fg = colors.yellow, bg = colors.none } }
    )
    return ret
  end,

  pretty_path = {
    LazyVim.lualine.pretty_path(),
    color = { bg = colors.none },
  },

  symbol = function()
    if not (vim.g.trouble_lualine and LazyVim.has("trouble.nvim")) then
      return {}
    end

    local trouble = require("trouble")
    local symbols = trouble.statusline({
      mode = "symbols",
      groups = {},
      title = false,
      filter = { range = true },
      format = "{kind_icon}{symbol.name:Normal}",
      hl_group = "lualine_c_normal",
    })
    return {
      symbols and symbols.get,
      cond = function()
        return vim.b.trouble_lualine ~= false and symbols.has()
      end,
    }
  end,

  filename = {
    "filename",
    icon = "󱉭",
    color = { bg = colors.none },
    cond = nil,
    path = 1,
  },

  diff = {
    "diff",
    symbols = {
      added = LazyVim.config.icons.git.added,
      modified = LazyVim.config.icons.git.modified,
      removed = LazyVim.config.icons.git.removed,
    },
    source = function()
      local gitsigns = vim.b.gitsigns_status_dict
      if gitsigns then
        return {
          added = gitsigns.added,
          modified = gitsigns.changed,
          removed = gitsigns.removed,
        }
      end
    end,
  },

  -- stylua: ignore
  dap = {
    function() return "  " .. require("dap").status() end,
    cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
    color = function() return { fg = Snacks.util.color("Debug") } end,
  },

  -- stylua: ignore
  lazy_status = {
    require("lazy.status").updates,
    cond = require("lazy.status").has_updates,
    color = function() return { fg = Snacks.util.color("Special") } end,
  },

  -- stylua: ignore
  noice_command = {
    function() return require("noice").api.status.command.get() end,
    color = function() return { fg = Snacks.util.color("Statement"), bg = colors.none } end,
    cond = function() return conditions.hide_in_width() and package.loaded["noice"] and require("noice").api.status.command.has() end,
  },

  -- stylua: ignore
  noice_mode = {
    function() return require("noice").api.status.mode.get() end,
    color = function() return { fg = Snacks.util.color("Constant"), bg = colors.none } end,
    cond = function() return conditions.hide_in_width() and package.loaded["noice"] and require("noice").api.status.mode.has() end,
  },

  scrollbar = {
    function()
      local current_line = vim.fn.line(".")
      local total_lines = vim.fn.line("$")
      local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
      local line_ratio = current_line / total_lines
      local index = math.ceil(line_ratio * #chars)
      return chars[index]
    end,
    color = { fg = colors.white, bg = colors.none },
    cond = conditions.hide_in_width,
  },

  -- stylua: ignore
  slogan = {
    function() return "虚一而静" end,
    color = { fg = colors.white, bg = colors.none },
    icon = "☯️",
    cond = conditions.hide_in_width,
  },
}

return M
