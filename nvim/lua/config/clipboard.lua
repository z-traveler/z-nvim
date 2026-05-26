local M = {}

local function timeout_prefix()
  if vim.fn.executable("timeout") ~= 1 then
    return ""
  end

  local timeout = vim.env.Z_NVIM_CLIPBOARD_TIMEOUT or "1s"
  if not timeout:match("^%d+%.?%d*[smhd]?$") then
    timeout = "1s"
  end

  return "timeout " .. timeout .. " "
end

local function detect_timeout()
  local timeout = vim.env.Z_NVIM_LEMONADE_DETECT_TIMEOUT or "0.1s"
  if not timeout:match("^%d+%.?%d*[smhd]?$") then
    timeout = "0.1s"
  end
  return timeout
end

local function infer_x11_display()
  if vim.env.Z_NVIM_X11_DISPLAY and vim.env.Z_NVIM_X11_DISPLAY ~= "" then
    return vim.env.Z_NVIM_X11_DISPLAY
  end

  if vim.env.DISPLAY and vim.env.DISPLAY ~= "" then
    return vim.env.DISPLAY
  end

  local ssh_client_host = (vim.env.SSH_CLIENT or ""):match("^(%S+)")
  if ssh_client_host and ssh_client_host ~= "" then
    return ssh_client_host .. ":0.0"
  end
end

local function setup_xclip()
  if vim.fn.executable("xclip") ~= 1 then
    return
  end

  local display = infer_x11_display()
  if not display then
    return
  end

  vim.env.DISPLAY = display
  local timeout = timeout_prefix()
  vim.g.clipboard = {
    name = "xclip-x11",
    copy = {
      ["+"] = "xclip -quiet -i -selection clipboard",
      ["*"] = "xclip -quiet -i -selection primary",
    },
    paste = {
      ["+"] = timeout .. "xclip -o -selection clipboard",
      ["*"] = timeout .. "xclip -o -selection primary",
    },
    cache_enabled = 0,
  }
end

local function setup_lemonade()
  if vim.fn.executable("lemonade") ~= 1 then
    return false
  end

  vim.g.clipboard = "lemonade"
  return true
end

local function lemonade_tunnel_ready()
  if vim.fn.executable("nc") ~= 1 then
    return false
  end

  local host = vim.env.Z_NVIM_LEMONADE_HOST or "127.0.0.1"
  local port = vim.env.Z_NVIM_LEMONADE_PORT or "2489"
  local cmd = { "nc", "-z", "-w", "1", host, port }
  if vim.fn.executable("timeout") == 1 then
    table.insert(cmd, 1, detect_timeout())
    table.insert(cmd, 1, "timeout")
  end
  local result = vim.system(cmd):wait()
  return result.code == 0
end

function M.setup()
  local provider = vim.env.Z_NVIM_CLIPBOARD

  if provider == "off" or provider == "none" then
    return
  end

  if provider == "xclip" or (vim.env.Z_NVIM_X11_DISPLAY and vim.env.Z_NVIM_X11_DISPLAY ~= "") then
    setup_xclip()
    return
  end

  if provider == "lemonade" or ((provider == nil or provider == "") and lemonade_tunnel_ready()) then
    setup_lemonade()
  end
end

return M
