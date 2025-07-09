local M = {}

function M.revert_buffer()
  local git_dir = vim.fn.system("git rev-parse --is-inside-work-tree")
  local svn_dir = vim.fn.system("svn info")

  if string.find(git_dir, "true") then
    vim.cmd("!git checkout -- %")
  elseif string.find(svn_dir, "Path:") then
    vim.cmd("!svn revert %")
  else
    vim.notify("No version control system found", vim.log.levels.ERROR)
  end
end

return M
