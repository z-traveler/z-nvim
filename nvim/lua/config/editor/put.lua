local M = {}

function M.current_location()
  local root = LazyVim.root()
  local file_path = vim.fn.expand("%:p")
  local line_num = vim.api.nvim_win_get_cursor(0)[1]
  file_path = string.sub(file_path, #root + 2)
  local info = string.format('File "%s", line %d', file_path, line_num)
  vim.fn.setreg("+", info)
  vim.fn.setreg('"', info)
end

function M.locate()
  local clip_content = vim.fn.getreg("+") -- 从剪切板读取内容
  local lines = vim.split(clip_content, "\n") -- 将剪切板内容按行分割
  local items = {} -- 用于存储解析出的文件和行号信息
  local root_dir = vim.fn.getcwd() -- 获取项目根目录

  for i, line in ipairs(lines) do
    local file_path, line_num

    -- 匹配 Python traceback 格式: File "路径", in 函数名
    file_path = line:match('^File "(.+)", in ')

    if file_path then
      -- 检查下一行是否有行号信息: > 行号: 代码
      local next_line = lines[i + 1]
      if next_line then
        line_num = next_line:match("^%s*>%s*(%d+):")
      end

      if line_num then
        -- 如果是绝对路径且文件存在，直接使用
        if file_path:match("^/") and vim.fn.filereadable(file_path) == 1 then
          table.insert(items, { filename = file_path, lnum = tonumber(line_num) })
        else
          -- 否则在项目中搜索文件
          local filename = file_path:match(".*/(.*)") or file_path
          local rg_cmd = string.format("rg --files '%s' | grep -m 1 '%s$'", root_dir, filename)
          local handle = io.popen(rg_cmd)
          local result = handle:read("*a")
          handle:close()

          local match_files = vim.split(result, "\n")
          if #match_files > 0 and match_files[1] ~= "" then
            -- 如果找到匹配的文件，使用第一个匹配
            table.insert(items, { filename = match_files[1], lnum = tonumber(line_num) })
          end
        end
      end
    end
  end

  -- 反转数组，使调用栈从上到下显示
  for i = 1, math.floor(#items / 2) do
    items[i], items[#items - i + 1] = items[#items - i + 1], items[i]
  end

  if #items == 1 then
    vim.cmd("edit " .. items[1].filename)
    vim.api.nvim_win_set_cursor(0, { items[1].lnum, 0 })
  elseif #items > 1 then
    vim.fn.setqflist(items)
    vim.cmd("copen")
  else
    vim.notify("No match found", vim.log.levels.WARN)
  end
end

return M
