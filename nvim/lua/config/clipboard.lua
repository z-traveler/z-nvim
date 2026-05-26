local M = {}

function M.setup()
  if not vim.env.DISPLAY or vim.env.DISPLAY == "" then
    return
  end

  if vim.fn.executable("xsel") == 1 then
    vim.g.clipboard = "xsel"
  end
end

return M
