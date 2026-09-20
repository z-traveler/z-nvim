local alt_directions = {
  h = { desc = "Left", motion = "left" },
  j = { desc = "Lower", motion = "down" },
  k = { desc = "Upper", motion = "up" },
  l = { desc = "Right", motion = "right" },
}

local terminal_jobs = {}

local function feed(keys)
  vim.api.nvim_feedkeys(vim.keycode(keys), "mx", false)
end

local function wait_for(predicate, message)
  assert(vim.wait(1000, predicate, 10), message)
end

local function find_window(filetype)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == filetype then
      return win
    end
  end
end

local function assert_normal_navigation_maps(win, context)
  vim.api.nvim_set_current_win(win)
  for key, direction in pairs(alt_directions) do
    local mapping = vim.fn.maparg("<M-" .. key .. ">", "n", false, true)
    assert(mapping.buffer == 0, ("%s overrides Alt-%s with a buffer-local normal-mode mapping"):format(context, key))
    assert(
      mapping.desc and mapping.desc:find(direction.desc, 1, true),
      ("%s Alt-%s is not the %s window navigation mapping"):format(context, key, direction.motion)
    )
  end
end

local function test_normal_window_navigation()
  vim.cmd("edit nvim/init.lua")
  vim.cmd("vsplit nvim/lua/config/keymaps.lua")
  local left = vim.api.nvim_get_current_win()
  vim.cmd("wincmd l")
  local right = vim.api.nvim_get_current_win()
  assert(left ~= right, "test setup needs two windows")

  feed("<M-h>")
  wait_for(function()
    return vim.api.nvim_get_current_win() == left
  end, "normal-mode Alt-h did not navigate to the left window")
end

local function test_terminal_navigation_maps()
  local source_win = vim.api.nvim_get_current_win()
  vim.cmd("botright new")
  local terminal_job = vim.fn.jobstart({ "sleep", "60" }, { term = true })
  assert(terminal_job > 0, "test terminal did not start")
  terminal_jobs[#terminal_jobs + 1] = terminal_job

  for key, direction in pairs(alt_directions) do
    local mapping = vim.fn.maparg("<M-" .. key .. ">", "t", false, true)
    assert(mapping.buffer == 0, ("terminal Alt-%s should use a global navigation mapping"):format(key))
    assert(type(mapping.callback) == "function", ("terminal Alt-%s navigation callback is missing"):format(key))
    assert(
      mapping.desc and mapping.desc:find(direction.desc, 1, true),
      ("terminal Alt-%s is not the %s pane/window navigation mapping"):format(key, direction.motion)
    )
  end

  vim.api.nvim_set_current_win(source_win)
end

local function test_snacks_picker_navigation()
  feed("<M-e>")
  wait_for(function()
    return find_window("snacks_picker_list") ~= nil
  end, "Alt-e did not open Snacks explorer")

  assert_normal_navigation_maps(assert(find_window("snacks_picker_list")), "Snacks picker list")
  assert_normal_navigation_maps(assert(find_window("snacks_picker_input")), "Snacks picker input")

  vim.api.nvim_set_current_win(assert(find_window("snacks_picker_list")))
  feed("<Esc>")
  wait_for(function()
    return find_window("snacks_picker_list") == nil
  end, "Snacks explorer did not close")
end

local function test_lazygit_terminal_navigation()
  Snacks.lazygit({ cwd = vim.fn.getcwd() })
  wait_for(function()
    return find_window("snacks_terminal") ~= nil
  end, "lazygit did not open")

  local terminal_win = assert(find_window("snacks_terminal"))
  local terminal_buf = vim.api.nvim_win_get_buf(terminal_win)
  terminal_jobs[#terminal_jobs + 1] = vim.b[terminal_buf].terminal_job_id

  for key, direction in pairs(alt_directions) do
    local mapping = vim.fn.maparg("<M-" .. key .. ">", "t", false, true)
    assert(mapping.buffer == 0, ("lazygit overrides the global Alt-%s terminal navigation mapping"):format(key))
    assert(type(mapping.callback) == "function", ("lazygit Alt-%s navigation callback is missing"):format(key))
    assert(
      mapping.desc and mapping.desc:find(direction.desc, 1, true),
      ("lazygit Alt-%s is not the %s pane/window navigation mapping"):format(key, direction.motion)
    )
  end

  local mapping = vim.fn.maparg("<M-l>", "t", false, true)
  vim.cmd.startinsert()
  wait_for(function()
    return vim.api.nvim_get_mode().mode:find("t", 1, true) ~= nil
  end, "lazygit did not enter terminal mode")
  mapping.callback()
  assert(vim.api.nvim_win_is_valid(terminal_win), "lazygit Alt-l mapping closed the floating terminal")
end

local ok, err = xpcall(function()
  test_normal_window_navigation()
  test_terminal_navigation_maps()
  test_snacks_picker_navigation()
  test_lazygit_terminal_navigation()
end, debug.traceback)

for _, terminal_job in ipairs(terminal_jobs) do
  vim.fn.jobstop(terminal_job)
end

if ok then
  print("Alt-h/j/k/l pane navigation ok")
  vim.cmd("cquit! 0")
else
  vim.api.nvim_err_writeln(err)
  vim.cmd("cquit! 1")
end
