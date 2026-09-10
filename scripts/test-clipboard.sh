#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
nvim_bin="${NVIM_BIN:-$(command -v nvim)}"
test_tmp="$(mktemp -d)"
trap 'rm -rf "$test_tmp"' EXIT

cat >"$test_tmp/lemonade" <<'FAKE_LEMONADE'
#!/bin/sh
printf '%s\n' "$@" >"$SSHL_TEST_ARGS"
/bin/sleep 1
/bin/cat >"$SSHL_TEST_COPY_OUTPUT"
FAKE_LEMONADE
chmod +x "$test_tmp/lemonade"

test_expr="package.path = '$repo_root/nvim/lua/?.lua;' .. package.path; require('config.clipboard').setup({ client = '$test_tmp/lemonade', timeout = 1500 }); local copy = vim.g.clipboard.copy['+']; local started = vim.uv.hrtime(); copy({ 'alpha', 'beta' }, 'V'); local elapsed = (vim.uv.hrtime() - started) / 1e6; assert(elapsed < 500, 'copy blocked for ' .. elapsed .. ' ms'); assert(vim.wait(2000, function() return vim.fn.filereadable('$test_tmp/copied') == 1 end), 'copy did not finish'); assert(vim.deep_equal(vim.fn.readfile('$test_tmp/copied'), { 'alpha', 'beta' }), 'copy changed clipboard text'); assert(vim.deep_equal(vim.fn.readfile('$test_tmp/args'), { '--host=127.0.0.1', '--port=2489', 'copy' }), 'copy used unexpected Lemonade arguments')"

SSHL_TEST_ARGS="$test_tmp/args" SSHL_TEST_COPY_OUTPUT="$test_tmp/copied" \
  "$nvim_bin" --clean --headless -u NONE \
  "+lua local ok, err = pcall(function() $test_expr end); if not ok then vim.api.nvim_err_writeln(err); vim.cmd('cquit') end" \
  "+qa"

cat >"$test_tmp/flaky-lemonade" <<'FAKE_LEMONADE'
#!/bin/sh
printf 'attempt\n' >>"$SSHL_TEST_ATTEMPTS"
if [ -f "$SSHL_TEST_READY" ]; then
  printf 'ready\n'
  exit 0
fi
exec /bin/sleep 2
FAKE_LEMONADE
chmod +x "$test_tmp/flaky-lemonade"

test_expr="package.path = '$repo_root/nvim/lua/?.lua;' .. package.path; require('config.clipboard').setup({ client = '$test_tmp/flaky-lemonade', timeout = 100, cooldown = 300 }); local paste = vim.g.clipboard.paste['+']; local started = vim.uv.hrtime(); local ok = pcall(paste); local elapsed = (vim.uv.hrtime() - started) / 1e6; assert(not ok, 'unavailable paste must fail'); assert(elapsed < 500, 'paste timeout took ' .. elapsed .. ' ms'); started = vim.uv.hrtime(); ok = pcall(paste); elapsed = (vim.uv.hrtime() - started) / 1e6; assert(not ok, 'paste during cooldown must fail'); assert(elapsed < 50, 'paste during cooldown took ' .. elapsed .. ' ms'); assert(#vim.fn.readfile('$test_tmp/attempts') == 1, 'cooldown started another client'); vim.fn.writefile({ 'ready' }, '$test_tmp/ready'); vim.wait(350); local value = paste(); assert(vim.deep_equal(value, { { 'ready' }, 'V' }), 'paste did not recover'); assert(#vim.fn.readfile('$test_tmp/attempts') == 2, 'paste did not retry after cooldown')"

SSHL_TEST_ATTEMPTS="$test_tmp/attempts" SSHL_TEST_READY="$test_tmp/ready" \
  "$nvim_bin" --clean --headless -u NONE \
  "+lua local ok, err = pcall(function() $test_expr end); if not ok then vim.api.nvim_err_writeln(err); vim.cmd('cquit') end" \
  "+qa"

rm -f "$test_tmp/attempts" "$test_tmp/ready"
test_expr="package.path = '$repo_root/nvim/lua/?.lua;' .. package.path; require('config.clipboard').setup({ client = '$test_tmp/flaky-lemonade', timeout = 100, cooldown = 300 }); local notifications = {}; vim.notify = function(message) table.insert(notifications, message) end; local copy = vim.g.clipboard.copy['+']; local started = vim.uv.hrtime(); copy({ 'alpha' }, 'v'); local elapsed = (vim.uv.hrtime() - started) / 1e6; assert(elapsed < 50, 'unavailable copy blocked for ' .. elapsed .. ' ms'); assert(vim.wait(500, function() return #notifications == 1 end), 'copy failure was not reported'); copy({ 'beta' }, 'v'); vim.wait(50); assert(#vim.fn.readfile('$test_tmp/attempts') == 1, 'copy ignored cooldown'); assert(#notifications == 1, 'copy failure was reported repeatedly'); vim.fn.writefile({ 'ready' }, '$test_tmp/ready'); vim.wait(350); copy({ 'gamma' }, 'v'); assert(vim.wait(500, function() return #vim.fn.readfile('$test_tmp/attempts') == 2 end), 'copy did not retry after cooldown')"

SSHL_TEST_ATTEMPTS="$test_tmp/attempts" SSHL_TEST_READY="$test_tmp/ready" \
  "$nvim_bin" --clean --headless -u NONE \
  "+lua local ok, err = pcall(function() $test_expr end); if not ok then vim.api.nvim_err_writeln(err); vim.cmd('cquit') end" \
  "+qa"
