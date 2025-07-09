local M = {}

function M.exchange_to_window_by_direction(direction)
  local state = {
    buf = vim.api.nvim_get_current_buf(),
    pos = vim.api.nvim_win_get_cursor(0),
  }

  local target_win = nil
  if direction == "leftmost" then
    target_win = M.get_leftmost_window()
  elseif direction == "rightmost" then
    target_win = M.get_rightmost_window()
  end

  if not target_win then
    vim.notify("Can not find " .. direction .. " window", vim.log.levels.WARN)
    return
  end

  if target_win == vim.api.nvim_get_current_win() then
    vim.notify("Already in " .. direction .. " window", vim.log.levels.INFO)
    return
  end

  vim.api.nvim_set_current_win(target_win)
  vim.api.nvim_set_current_buf(state.buf)
  vim.api.nvim_win_set_cursor(0, state.pos)

  local goto_preview = require("goto-preview")
  if goto_preview and goto_preview.close_all_win then
    goto_preview.close_all_win()
  end
end

function M.get_leftmost_window()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local leftmost_win = nil
  local leftmost_col = math.huge

  for _, win in ipairs(wins) do
    local pos = vim.api.nvim_win_get_position(win)
    if pos[2] < leftmost_col then
      leftmost_col = pos[2]
      leftmost_win = win
    end
  end

  return leftmost_win
end

function M.get_rightmost_window()
  local wins = vim.api.nvim_tabpage_list_wins(0)
  local rightmost_win = nil
  local rightmost_col = -1

  for _, win in ipairs(wins) do
    local pos = vim.api.nvim_win_get_position(win)
    local width = vim.api.nvim_win_get_width(win)
    local right_edge = pos[2] + width

    if right_edge > rightmost_col then
      rightmost_col = right_edge
      rightmost_win = win
    end
  end

  return rightmost_win
end

function M.exchange_to_left()
  M.exchange_to_window_by_direction("leftmost")
end

function M.exchange_to_right()
  M.exchange_to_window_by_direction("rightmost")
end

return M
