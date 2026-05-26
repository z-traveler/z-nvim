#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
nvim_bin="${NVIM_BIN:-$(command -v nvim)}"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

run_lua() {
  local path_value="$1"
  local display_value="${2-}"
  local lua_expr="$3"
  if [[ -n "$display_value" ]]; then
    env DISPLAY="$display_value" PATH="$path_value" "$nvim_bin" --clean --headless -u NONE \
      "+lua package.path = '$repo_root/nvim/lua/?.lua;$repo_root/nvim/lua/?/init.lua;' .. package.path; require('config.clipboard').setup(); $lua_expr" \
      "+qa"
  else
    env -u DISPLAY PATH="$path_value" "$nvim_bin" --clean --headless -u NONE \
      "+lua package.path = '$repo_root/nvim/lua/?.lua;$repo_root/nvim/lua/?/init.lua;' .. package.path; require('config.clipboard').setup(); $lua_expr" \
      "+qa"
  fi
}

mkdir -p "$tmp/bin" "$tmp/empty"
cat >"$tmp/bin/xsel" <<'FAKE_XSEL'
#!/usr/bin/env sh
exit 0
FAKE_XSEL
chmod +x "$tmp/bin/xsel"

run_lua "$tmp/bin" "10.226.150.62:0" "assert(vim.g.clipboard == 'xsel', 'expected xsel clipboard provider')"
run_lua "$tmp/bin" "" "assert(vim.g.clipboard ~= 'xsel', 'xsel must not be selected without DISPLAY')"
run_lua "$tmp/empty" "10.226.150.62:0" "assert(vim.g.clipboard ~= 'xsel', 'xsel must not be selected when xsel is missing')"
