local M = {}

function M.toggle_quickfix()
  local windows = vim.fn.getwininfo()
  for _, win in pairs(windows) do
    if win["quickfix"] == 1 then
      vim.cmd.cclose()
      return
    end
  end
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd.copen()
  end
end

function M.toggle_loclist()
  local windows = vim.fn.getwininfo()
  for _, win in pairs(windows) do
    if win["loclist"] == 1 then
      vim.cmd.lclose()
      return
    end
  end
  if not vim.tbl_isempty(vim.fn.getloclist(0)) then
    vim.cmd.lopen()
  end
end

return M
