local M = {}

function M.toggle_quickfix()
  local qf_exists = false
  for _, win in pairs(vim.fn.getwininfo()) do
    if win["quickfix"] == 1 then
      qf_exists = true
    end
  end
  if qf_exists == true then
    vim.cmd("cclose")
    return
  end
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd("copen")
  end
end

function M.buf_kill(kill_command, bufnr, force)
  kill_command = kill_command or "bd"

  local bo = vim.bo
  local api = vim.api
  local fmt = string.format
  local fnamemodify = vim.fn.fnamemodify

  if bufnr == 0 or bufnr == nil then
    bufnr = api.nvim_get_current_buf()
  end

  local bufname = api.nvim_buf_get_name(bufnr)

  if not force then
    local warning
    if bo[bufnr].modified then
      warning = fmt([[No write since last change for (%s)]], fnamemodify(bufname, ":t"))
    elseif api.nvim_buf_get_option(bufnr, "buftype") == "terminal" then
      warning = fmt([[Terminal %s will be killed]], bufname)
    end
    if warning then
      vim.ui.input({
        prompt = string.format([[%s. Close it anyway? [y]es or [n]o (default: no): ]], warning),
      }, function(choice)
        if choice:match("ye?s?") then
          force = true
        end
      end)
      if not force then
        return
      end
    end
  end

  -- 获取显示该buffer的所有窗口
  local windows = vim.tbl_filter(function(win)
    return api.nvim_win_get_buf(win) == bufnr
  end, api.nvim_list_wins())

  if #windows == 0 then
    return
  end

  -- 获取当前窗口
  local current_win = api.nvim_get_current_win()

  -- 检查当前窗口是否在显示该buffer的窗口列表中
  local current_win_showing_buffer = vim.tbl_contains(windows, current_win)

  -- 获取其他可用的buffer
  local buffers = vim.tbl_filter(function(buf)
    return api.nvim_buf_is_valid(buf) and bo[buf].buflisted and buf ~= bufnr
  end, api.nvim_list_bufs())

  -- 如果有多个窗口显示该buffer，只替换当前窗口
  if #windows > 1 then
    if current_win_showing_buffer and #buffers > 0 then
      -- 尝试使用之前的buffer信息
      local win_prev_info = M.prev_bufs and M.prev_bufs[current_win]
      if
        win_prev_info
        and api.nvim_buf_is_valid(win_prev_info[1])
        and bo[win_prev_info[1]].buflisted
        and win_prev_info[1] ~= bufnr
      then
        api.nvim_win_set_buf(current_win, win_prev_info[1])
        api.nvim_win_set_cursor(current_win, win_prev_info[2])
      else
        -- 使用第一个可用buffer作为后备
        api.nvim_win_set_buf(current_win, buffers[1])
        api.nvim_win_set_cursor(current_win, { 1, 0 })
      end
    end
    -- 不删除buffer，因为还有其他窗口在使用
    return
  end

  -- 只有一个窗口显示该buffer时，按原逻辑处理
  if #buffers > 0 then
    local fallback_buffer = buffers[1]

    for _, win in ipairs(windows) do
      local switched = false

      -- 尝试使用之前的buffer信息
      local win_prev_info = M.prev_bufs and M.prev_bufs[win]
      if
        win_prev_info
        and api.nvim_buf_is_valid(win_prev_info[1])
        and bo[win_prev_info[1]].buflisted
        and win_prev_info[1] ~= bufnr
      then
        api.nvim_win_set_buf(win, win_prev_info[1])
        api.nvim_win_set_cursor(win, win_prev_info[2])
        switched = true
      end

      -- 如果没有成功切换，使用后备buffer
      if not switched then
        api.nvim_win_set_buf(win, fallback_buffer)
        api.nvim_win_set_cursor(win, { 1, 0 })
      end
    end
  end

  if force then
    kill_command = kill_command .. "!"
  end

  -- 只有当只有一个窗口显示该buffer时才真正删除
  if api.nvim_buf_is_valid(bufnr) and bo[bufnr].buflisted then
    vim.cmd(string.format("%s %d", kill_command, bufnr))
  end
end

return M
