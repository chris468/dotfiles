eval "$(/usr/bin/env bash ~/.config/dircolors/dircolors.sh)"

if command -v gls >/dev/null 2>&1; then
	alias ls='gls --color=auto'
fi
