local M = {}

local colors = {
  none = "none",
  color_bg = "#151d29",
  light_bg = "#16191f",
  fg = "#bbc2cf",
  dark_fg = "#2e314a",
  yellow = "#ecbe7b",
  cyan = "#7caea3",
  darkblue = "#081633",
  green = "#98be65",
  light_green = "#eaff8f",
  orange = "#fac03d",
  violet = "#a9a1e1",
  magenta = "#c678dd",
  purple = "#c678dd",
  blue = "#51afef",
  light_blue = "#8aabcc",
  white = "#d4e5ef",
  dim_white = "#86908a",
  dim_yellow = "#fffbc7",
  light_cyan = "#91d5ff",
  red = "#ec5f67",
}
M.colors = colors

local function update_hl(group_name, new)
  local current_hl = vim.api.nvim_get_hl(0, { name = group_name }) or {}
  if new.link == nil then
    current_hl = {}
  end
  vim.api.nvim_set_hl(0, group_name, vim.tbl_extend("force", current_hl, new))
end

M.update_hl = update_hl

return M
