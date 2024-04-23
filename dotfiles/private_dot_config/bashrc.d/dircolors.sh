if [ -x /usr/bin/dircolors ]; then
	eval "$(/usr/bin/env bash ~/.config/dircolors/dircolors.sh)"

	if command -v gls >/dev/null 2>&1; then
		alias ls='gls --color=auto'
	else
		alias ls='ls --color=auto'
	fi

	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi
