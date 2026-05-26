local M = {}

local function detect_timeout_ms()
  local timeout = vim.env.Z_NVIM_LEMONADE_DETECT_TIMEOUT or "0.1s"
  local value, unit = timeout:match("^(%d+%.?%d*)([smhd]?)$")
  if not value then
    return 100
  end

  local seconds = tonumber(value)
  if unit == "m" then
    seconds = seconds * 60
  elseif unit == "h" then
    seconds = seconds * 3600
  elseif unit == "d" then
    seconds = seconds * 86400
  end
  return math.max(1, math.floor(seconds * 1000))
end

local function setup_xsel()
  if vim.env.DISPLAY and vim.env.DISPLAY ~= "" and vim.fn.executable("xsel") == 1 then
    vim.g.clipboard = "xsel"
    return true
  end
  return false
end

local function lemonade_tunnel_ready()
  if vim.fn.executable("nc") ~= 1 then
    return false
  end

  local host = vim.env.Z_NVIM_LEMONADE_HOST or "127.0.0.1"
  local port = vim.env.Z_NVIM_LEMONADE_PORT or "2489"
  local port_check = vim.system({ "nc", "-z", "-w", "1", host, port }):wait()
  if port_check.code ~= 0 then
    return false
  end

  local probe = vim.system({ "lemonade", "paste" }, { text = false })
  local result = probe:wait(detect_timeout_ms())
  if not result then
    probe:kill(15)
    return false
  end
  return result.code == 0
end

local function setup_lemonade(force)
  if vim.fn.executable("lemonade") ~= 1 then
    return false
  end

  if force or lemonade_tunnel_ready() then
    vim.g.clipboard = "lemonade"
    return true
  end

  return false
end

function M.setup()
  local provider = vim.env.Z_NVIM_CLIPBOARD

  if provider == "off" or provider == "none" then
    return
  end

  if provider == "lemonade" then
    setup_lemonade(true)
    return
  end

  if provider == "xsel" then
    setup_xsel()
    return
  end

  if setup_lemonade(false) then
    return
  end

  setup_xsel()
end

return M
