local config = dofile("nvim/lua/plugins/ui/dashboard.lua")
local dashboard = assert(config[1].opts.dashboard, "dashboard config exists")
local header = assert(dashboard.preset.header, "dashboard header exists")

local widths = {}
for _, line in ipairs(vim.split(header, "\n", { plain = true, trimempty = false })) do
  if line:match("%S") then
    widths[#widths + 1] = vim.fn.strdisplaywidth(line)
  end
end

assert(#widths > 0, "header has visible lines")

local header_width = widths[1]
for index, width in ipairs(widths) do
  assert(
    width == header_width,
    ("header line %d width %d differs from first visible line width %d"):format(index, width, header_width)
  )
end

local effective_dashboard_width = dashboard.width or 60
assert(
  effective_dashboard_width == header_width,
  ("dashboard width %d must match header width %d so pane 2 rows align"):format(effective_dashboard_width, header_width)
)

print("dashboard header alignment ok")
