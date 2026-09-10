-- Stable Neovim provider: configure once, reconnect on each operation.
-- No startup probe, so a late/restarted tunnel works without restarting Neovim.
local M = {}
function M.setup(opts)
  opts = opts or {}
  local mode = vim.env.Z_NVIM_CLIPBOARD
  if mode == "off" or mode == "none" then
    return
  end
  if mode == "xsel" then
    vim.g.clipboard = "xsel"
    return
  end
  local client = opts.client or vim.fn.exepath("lemonade")
  if client == "" then
    local candidate = vim.fn.expand("~/.local/bin/lemonade")
    if vim.fn.executable(candidate) == 1 then
      client = candidate
    end
  end
  if client == "" then
    return
  end
  local host = opts.host or vim.env.Z_NVIM_LEMONADE_HOST or "127.0.0.1"
  local port = tostring(opts.port or vim.env.Z_NVIM_LEMONADE_PORT or "2489")
  local limit = opts.timeout or 500
  local cooldown = opts.cooldown or 5000
  local unavailable_until = 0
  local failure_reported = false
  local operation = 0
  local unavailable_message = "sshl clipboard unavailable; reconnect with sshl"
  local function circuit_open()
    return vim.uv.hrtime() / 1e6 < unavailable_until
  end
  local function mark_unavailable(report)
    unavailable_until = vim.uv.hrtime() / 1e6 + cooldown
    if failure_reported then
      return
    end
    failure_reported = true
    if report then
      vim.schedule(function()
        vim.notify(unavailable_message, vim.log.levels.WARN)
      end)
    end
  end
  local function mark_available()
    unavailable_until = 0
    failure_reported = false
  end
  local function next_operation()
    operation = operation + 1
    return operation
  end
  local function run(op, data)
    local process = vim.system({ client, "--host=" .. host, "--port=" .. port, op }, { stdin = data, text = true })
    local result = process:wait(limit)
    return result.code == 0 and (result.stdout or "") or nil
  end
  local function copy(lines, regtype)
    if circuit_open() then
      return
    end
    local text = table.concat(lines, "\n")
    if regtype == "V" then
      text = text .. "\n"
    end
    local current_operation = next_operation()
    vim.system(
      { client, "--host=" .. host, "--port=" .. port, "copy" },
      { stdin = text, text = true, timeout = limit },
      function(result)
        if current_operation ~= operation then
          return
        end
        if result.code == 0 then
          mark_available()
        else
          mark_unavailable(true)
        end
      end
    )
  end
  local function paste()
    if circuit_open() then
      error(unavailable_message)
    end
    next_operation()
    local output = run("paste")
    if not output then
      mark_unavailable(false)
      error(unavailable_message)
    end
    mark_available()
    local text = output:gsub("\r\n", "\n")
    local linewise = text:sub(-1) == "\n"
    if linewise then
      text = text:sub(1, -2)
    end
    return { vim.split(text, "\n", { plain = true }), linewise and "V" or "v" }
  end
  vim.g.clipboard = {
    name = "sshl (Lemonade)",
    copy = { ["+"] = copy, ["*"] = copy },
    paste = { ["+"] = paste, ["*"] = paste },
    cache_enabled = 0,
  }
end
return M
