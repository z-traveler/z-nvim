#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
nvim_bin="${NVIM_BIN:-$(command -v nvim)}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

run_lua() {
  local path_value="$1"
  local display_value="$2"
  local lua_expr="$3"
  shift 3
  if [[ -n "$display_value" ]]; then
    env "$@" DISPLAY="$display_value" PATH="$path_value" "$nvim_bin" --clean --headless -u NONE \
      "+lua package.path = '$repo_root/nvim/lua/?.lua;$repo_root/nvim/lua/?/init.lua;' .. package.path; require('config.clipboard').setup(); $lua_expr" \
      "+qa"
  else
    env "$@" -u DISPLAY PATH="$path_value" "$nvim_bin" --clean --headless -u NONE \
      "+lua package.path = '$repo_root/nvim/lua/?.lua;$repo_root/nvim/lua/?/init.lua;' .. package.path; require('config.clipboard').setup(); $lua_expr" \
      "+qa"
  fi
}

mkdir -p "$tmp/bin" "$tmp/empty"
cat >"$tmp/bin/xsel" <<'FAKE_XSEL'
#!/bin/sh
exit 0
FAKE_XSEL
chmod +x "$tmp/bin/xsel"

cat >"$tmp/bin/lemonade" <<'FAKE_LEMONADE'
#!/bin/sh
exit 0
FAKE_LEMONADE
chmod +x "$tmp/bin/lemonade"

cat >"$tmp/bin/nc" <<'FAKE_NC'
#!/bin/sh
exit 0
FAKE_NC
chmod +x "$tmp/bin/nc"

run_lua "$tmp/bin" "" "assert(vim.g.clipboard == 'lemonade', 'expected lemonade clipboard provider')"
run_lua "$tmp/bin" "10.226.150.62:0" "assert(vim.g.clipboard == 'lemonade', 'lemonade must be preferred over xsel')"

cat >"$tmp/bin/lemonade" <<'SLOW_LEMONADE'
#!/bin/sh
/bin/sleep 1
exit 0
SLOW_LEMONADE
chmod +x "$tmp/bin/lemonade"
run_lua "$tmp/bin" "10.226.150.62:0" "assert(vim.g.clipboard == 'xsel', 'slow lemonade probe must fall back to xsel')" Z_NVIM_LEMONADE_DETECT_TIMEOUT=0.05s

rm -f "$tmp/bin/lemonade"
run_lua "$tmp/bin" "10.226.150.62:0" "assert(vim.g.clipboard == 'xsel', 'expected xsel fallback provider')"
run_lua "$tmp/bin" "" "assert(vim.g.clipboard ~= 'xsel', 'xsel must not be selected without DISPLAY')"
run_lua "$tmp/empty" "10.226.150.62:0" "assert(vim.g.clipboard ~= 'xsel', 'xsel must not be selected when xsel is missing')"
run_lua "$tmp/bin" "10.226.150.62:0" "assert(vim.g.clipboard ~= 'xsel', 'clipboard provider should be disabled by override')" Z_NVIM_CLIPBOARD=off
