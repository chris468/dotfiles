#!/usr/bin/env bash

tmux display -p '#S' | grep -qE '^[0-9]+$' || exit 0

name="$(basename $(pwd))"
suffix=

while [ -n "$(tmux list-sessions -f "#{N/s:$name$suffix}")" ]; do
	let suffix=$suffix-1
done

tmux rename-session "$name$suffix"
