#!/usr/bin/env bash
#
APPS=(glances htop top)

for app in ${APPS[@]}; do
	if command -v $app &>/dev/null; then
		$app
		exit
	fi
done

message="No monitoring app found: ${APPS[@]}"
if [ -z "$TMUX" ]; then
	echo "$message" >2
else
	tmux display-message "#[fg=##d08770]$message"
fi

exit 1
