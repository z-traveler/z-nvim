local M = {}

function _G.create_floating_terminal_cmd(cmd)
  local width = math.floor(vim.o.columns * 0.4)
  local height = math.floor(vim.o.lines * 0.3)

  local terminal_opts = {
    win = {
      width = width,
      height = height,
      row = vim.o.lines - height - 3, -- 底部位置
      col = vim.o.columns - width - 2, -- 右侧位置
      border = "rounded",
      title = "",
      title_pos = "center",
    },
    start_insert = false,
    auto_insert = false,
    auto_close = true,
  }
  return Snacks.terminal.open(cmd, terminal_opts)
end

return M
