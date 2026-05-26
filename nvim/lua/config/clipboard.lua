local M = {}

local function timeout_ms()
  local timeout = vim.env.Z_NVIM_LEMONADE_DETECT_TIMEOUT or "1s"
  local value, unit = timeout:match("^(%d+%.?%d*)([smhd]?)$")
  if not value then
    return 1000
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

local function lemonade_host()
  return vim.env.Z_NVIM_LEMONADE_HOST or "127.0.0.1"
end

local function lemonade_port()
  return vim.env.Z_NVIM_LEMONADE_PORT or "2489"
end

local function lemonade_cmd(subcmd)
  return { "lemonade", "--host=" .. lemonade_host(), "--port=" .. lemonade_port(), subcmd }
end

local function setup_xsel()
  if vim.env.DISPLAY and vim.env.DISPLAY ~= "" and vim.fn.executable("xsel") == 1 then
    vim.g.clipboard = "xsel"
    return true
  end
  return false
end

local function lemonade_tunnel_ready()
  if vim.fn.executable("lemonade") ~= 1 then
    return false
  end

  -- Do NOT use nc/telnet to probe lemonade: a bare TCP connection can wedge
  -- lemonade's RPC server. Probe with a real lemonade RPC and a sane timeout.
  local probe = vim.system(lemonade_cmd("paste"), { text = false })
  local result = probe:wait(timeout_ms())
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

  if not force and not lemonade_tunnel_ready() then
    return false
  end

  vim.g.clipboard = {
    name = "lemonade",
    copy = {
      ["+"] = lemonade_cmd("copy"),
      ["*"] = lemonade_cmd("copy"),
    },
    paste = {
      ["+"] = lemonade_cmd("paste"),
      ["*"] = lemonade_cmd("paste"),
    },
    cache_enabled = 0,
  }
  return true
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
