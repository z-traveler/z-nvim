#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
socket="z-nvim-pane-navigation-$$"
server="${TMPDIR:-/tmp}/z-nvim-pane-navigation-$$.sock"

cleanup() {
  tmux -L "$socket" kill-server 2>/dev/null || true
  rm -f "$server"
}
cleanup
trap cleanup EXIT

TMUX='' XDG_CONFIG_HOME="$repo_root" nvim --headless \
  "+lua dofile('$repo_root/scripts/test-pane-navigation.lua')"
printf "\n"

tmux -L "$socket" -f /dev/null new-session -d -x 120 -y 40 -c "$repo_root" \
  "XDG_CONFIG_HOME='$repo_root' nvim --listen '$server'"
tmux -L "$socket" split-window -h -d "sleep 30"

left_pane=$(tmux -L "$socket" list-panes -F '#{pane_id}' | head -1)
right_pane=$(tmux -L "$socket" list-panes -F '#{pane_id}' | tail -1)

ready=false
for _ in {1..50}; do
  if tmux -L "$socket" capture-pane -p -t "$left_pane" | grep -q "[^[:space:]]"; then
    ready=true
    break
  fi
  sleep 0.1
done
$ready || exit 1

tmux -L "$socket" send-keys -t "$left_pane" Space v g
ready=false
for _ in {1..50}; do
  if tmux -L "$socket" capture-pane -p -t "$left_pane" | grep -q "Stage:"; then
    ready=true
    break
  fi
  sleep 0.1
done
$ready || exit 1
lazygit_win=$(nvim --server "$server" --remote-expr 'win_getid()')

tmux -L "$socket" send-keys -t "$left_pane" M-l
switched=false
for _ in {1..20}; do
  if [[ $(tmux -L "$socket" display-message -p '#{pane_id}') == "$right_pane" ]]; then
    switched=true
    break
  fi
  sleep 0.1
done

if ! $switched; then
  tmux -L "$socket" capture-pane -p -t "$left_pane" >&2
  exit 1
fi

tmux -L "$socket" select-pane -t "$left_pane"
current_win=$(nvim --server "$server" --remote-expr 'win_getid()')
current_filetype=$(nvim --server "$server" --remote-expr 'luaeval("vim.bo.filetype")')
if [[ $current_win != "$lazygit_win" || $current_filetype != "snacks_terminal" ]]; then
  echo "lazygit was not preserved after Alt-l navigation" >&2
  exit 1
fi

echo "lazygit Alt-l tmux navigation preserves lazygit"
