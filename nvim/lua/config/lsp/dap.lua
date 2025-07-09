local M = {}

local ns_id = vim.api.nvim_create_namespace("my_dap_namespace")
local extmark_id_to_info = {}
local dap_lock = false

function M.clear_dap_all()
  for extmark_id, info in pairs(extmark_id_to_info) do
    local bufnr = info[1]
    vim.api.nvim_buf_del_extmark(bufnr, ns_id, extmark_id)
  end
  dap_lock = false
  extmark_id_to_info = {}
end

function M.custom_breakpoint(breakpoint)
  if dap_lock then
    vim.notify("Waiting For Last Breakpoint Operator", vim.log.levels.WARN, { title = "DAP" })
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row = cursor_pos[1]
  local path = vim.api.nvim_buf_get_name(bufnr)
  path = vim.fn.fnamemodify(path, ":.")
  local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, ns_id, { row - 1, 0 }, { row - 1, -1 }, { details = true })
  local dap = require("dap")

  -- 检查当前行是否已经有虚拟文本（断点）
  local cancel_info = nil
  if #extmarks > 0 then
    for _, extmark in ipairs(extmarks) do
      local extmark_id = extmark[1]
      local saved_info = extmark_id_to_info[extmark_id]
      if saved_info and saved_info[3] == breakpoint then
        cancel_info = { extmark_id, saved_info }
        break
      end
    end
  end

  if cancel_info then
    -- 取消
    dap_lock = true
    dap.pause(0) -- like ctrl-c, pause all threads
    dap.listeners.after.event_stopped["z.pause"] = function(_, _)
      dap.listeners.after.event_stopped["z.pause"] = nil
      dap.listeners.after.stackTrace["z.pause.stackTrace"] = function(_, _, _, _, _)
        dap.listeners.after.stackTrace["z.pause.stackTrace"] = nil
        if cancel_info[2][4] ~= -1 then
          dap.repl.execute("-exec delete " .. cancel_info[2][4])
        else
          dap.repl.execute("-exec clear " .. path .. ":" .. cancel_info[2][2])
        end
        dap.listeners.after.evaluate["z.pause.stackTrace.evaluate"] = function(_, _, _, _, _)
          dap.listeners.after.evaluate["z.pause.stackTrace.evaluate"] = nil
          dap.continue()
          dap.listeners.after.continue["z.pause.stackTrace.evaluate.continue"] = function(_, _, _, _, _)
            dap.listeners.after.continue["z.pause.stackTrace.evaluate.continue"] = nil
            print("continue")
            vim.api.nvim_buf_del_extmark(bufnr, ns_id, cancel_info[1])
            extmark_id_to_info[cancel_info[1]] = nil
            dap_lock = false
          end
        end
      end
    end
  else
    -- 添加
    vim.cmd("normal! $")
    local event = require("nui.utils.autocmd").event
    local input = require("nui.input")({
      relative = "cursor",
      position = {
        row = 1,
        col = 0,
      },
      size = 60,
      border = {
        style = "rounded",
        text = {
          top = require("nui.text")("[" .. breakpoint .. "]", "Error"),
          top_align = "left",
        },
      },
      win_options = {
        winhighlight = "Normal:Normal",
      },
    }, {
      prompt = "🐤 ",
      on_submit = function(value)
        dap_lock = true
        dap.pause(0)
        dap.listeners.after.event_stopped["z.pause"] = function(_, _)
          dap.listeners.after.event_stopped["z.pause"] = nil
          dap.listeners.after.stackTrace["z.pause.stackTrace"] = function(_, _, _, _, _)
            dap.listeners.after.stackTrace["z.pause.stackTrace"] = nil
            -- 这里依赖frameID, pause后还没有frameID, 会再次请求stackTrace
            dap.repl.execute("-exec " .. breakpoint .. " " .. path .. ":" .. row .. " " .. value:gsub(",", " "))
            dap.listeners.after.evaluate["z.pause.stackTrace.evaluate"] = function(_, _, evaluate_resp, _, _)
              dap.listeners.after.evaluate["z.pause.stackTrace.evaluate"] = nil
              local breakpoint_id = -1
              for rline in evaluate_resp.result:gmatch("([^\n]+)") do
                local bd = rline:match("Breakpoint (%d+) at 0x[0-9a-f]+:.*")
                if bd then
                  breakpoint_id = bd
                  break
                end
              end
              dap.continue()
              dap.listeners.after.continue["z.pause.stackTrace.evaluate.continue"] = function(_, _, _, _, _)
                dap.listeners.after.continue["z.pause.stackTrace.evaluate.continue"] = nil
                local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1]
                local extmark_id = vim.api.nvim_buf_set_extmark(bufnr, ns_id, row - 1, #line, {
                  virt_text = { { "  🐤 " .. breakpoint .. "(" .. value .. ")", "TSCharacterSpecial" } },
                  virt_text_pos = "eol", -- 将虚拟文本放在行尾
                  hl_mode = "combine", -- 允许与现有高亮组合
                })
                extmark_id_to_info[extmark_id] = { bufnr, row, breakpoint, breakpoint_id }
                print(vim.inspect(extmark_id_to_info[extmark_id]))
                dap_lock = false
              end
            end
          end
        end
      end,
    })
    input:mount()
    input:map("n", "<ESC>", function()
      input:unmount()
    end, { noremap = true })
    input:map("n", "q", function()
      input:unmount()
    end, { noremap = true })
    input:map("n", "Q", function()
      input:unmount()
    end, { noremap = true })
    input:on(event.BufLeave, function()
      input:unmount()
    end)
  end
end

local function clear_dap_all()
  for extmark_id, info in pairs(extmark_id_to_info) do
    local bufnr = info[1]
    vim.api.nvim_buf_del_extmark(bufnr, ns_id, extmark_id)
  end
  dap_lock = false
  extmark_id_to_info = {}
end

function M.clear_all()
    local dap, dapui = require("dap"), require("dapui")
    dap.disconnect();
    dapui.close()
    clear_dap_all()
    vim.opt.mouse = ""
end

return M
