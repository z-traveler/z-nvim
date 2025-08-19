local M = {}

function M.get_repo_version_manager()
  local git_dir = vim.fn.system("git rev-parse --is-inside-work-tree")
  local svn_dir = vim.fn.system("svn info")
  if string.find(git_dir, "true") then
    return "git"
  end
  if string.find(svn_dir, "Path:") then
    return "svn"
  end
end

function M.revert_buffer()
  local repo_version_manager = M.get_repo_version_manager()
  if repo_version_manager == "git" then
    vim.cmd("!git checkout -- %")
  elseif repo_version_manager == "svn" then
    vim.cmd("!svn revert %")
  else
    vim.notify("No version control system found", vim.log.levels.ERROR)
  end
end

function M.diff_buffer()
  local repo_version_manager = M.get_repo_version_manager()
  if repo_version_manager == "git" then
    vim.cmd("Gitsigns diffthis")
  elseif repo_version_manager == "svn" then
    vim.cmd("SignifyDiff!")
  end
end

function M.revert_hunk()
  local repo_version_manager = M.get_repo_version_manager()
  if repo_version_manager == "git" then
    vim.cmd("Gitsigns reset_hunk")
  elseif repo_version_manager == "svn" then
    vim.cmd("SignifyHunkUndo")
  end
end

function M.diff_hunk()
  vim.cmd("SignifyHunkDiff")
end

function M.blame_buffer()
  local repo_version_manager = M.get_repo_version_manager()
  if repo_version_manager == "git" then
    vim.cmd("Gitsigns blame")
  elseif repo_version_manager == "svn" then
    vim.cmd("VCBlame")
  end
end

function M.log()
  local repo_version_manager = M.get_repo_version_manager()
  if repo_version_manager == "git" then
    Snacks.picker.git_log_file()
  elseif repo_version_manager == "svn" then
    vim.cmd("VCLog")
  end
end

return M
