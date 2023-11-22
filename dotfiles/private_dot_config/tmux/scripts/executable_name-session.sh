#!/usr/bin/env bash

name="$(basename $(pwd))"
suffix=

while [ -n "$(tmux list-sessions -f "#{N/s:$name$suffix}")" ]; do
	let suffix=$suffix-1
done

tmux rename-session "$name$suffix"
