local function normal_window()
  local previous = vim.fn.win_getid(vim.fn.winnr("#"))
  if previous ~= 0 and vim.api.nvim_win_is_valid(previous) and vim.api.nvim_win_get_config(previous).relative == "" then
    return previous
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).relative == "" then
      return win
    end
  end
end

local function navigate(command)
  return function()
    local float = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_config(float).relative ~= "" then
      -- 从浮窗下方的普通窗口计算方向；跨 tmux pane 后恢复浮窗焦点。
      local previous = normal_window()
      if previous then
        vim.api.nvim_set_current_win(previous)
        vim.cmd(command)
        if vim.api.nvim_get_current_win() == previous and vim.api.nvim_win_is_valid(float) then
          vim.api.nvim_set_current_win(float)
        end
        return
      end
    end
    vim.cmd(command)
  end
end

return {
  "christoomey/vim-tmux-navigator",
  init = function()
    vim.g.tmux_navigator_no_mappings = 1
    vim.g.tmux_navigator_disable_when_zoomed = 1
  end,
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
    "TmuxNavigatorProcessList",
  },
  keys = {
    { "<A-h>", "<cmd>TmuxNavigateLeft<cr>", mode = "n", desc = "Go To Left Window", noremap = true, silent = true },
    { "<A-j>", "<cmd>TmuxNavigateDown<cr>", mode = "n", desc = "Go To Lower Window", noremap = true, silent = true },
    { "<A-k>", "<cmd>TmuxNavigateUp<cr>", mode = "n", desc = "Go To Upper Window", noremap = true, silent = true },
    { "<A-l>", "<cmd>TmuxNavigateRight<cr>", mode = "n", desc = "Go to Right Window", noremap = true, silent = true },
    {
      "<A-h>",
      navigate("TmuxNavigateLeft"),
      mode = "t",
      desc = "Go To Left Window",
      noremap = true,
      silent = true,
    },
    {
      "<A-j>",
      navigate("TmuxNavigateDown"),
      mode = "t",
      desc = "Go To Lower Window",
      noremap = true,
      silent = true,
    },
    {
      "<A-k>",
      navigate("TmuxNavigateUp"),
      mode = "t",
      desc = "Go To Upper Window",
      noremap = true,
      silent = true,
    },
    {
      "<A-l>",
      navigate("TmuxNavigateRight"),
      mode = "t",
      desc = "Go to Right Window",
      noremap = true,
      silent = true,
    },
  },
}
