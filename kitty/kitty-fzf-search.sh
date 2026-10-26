#!/usr/bin/env bash

tmp=$(mktemp)
cat > "$tmp"

sel=$(nl -ba "$tmp" | fzf --no-sort --tac --prompt='Search: ' | awk '{print $1}')

if [ -n "$sel" ]; then
  kitty @ scroll-to --match-line $((sel - 1))
fi

rm -f "$tmp"
