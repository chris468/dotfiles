__theme=~/.config/dircolors/nord

if [ -r "$__theme" ]; then
	__dircolors=
	for cmd in dircolors gdircolors; do
		command -v $cmd null >/dev/null 2>&1 && __dircolors=$cmd && break
	done
	if [ -n "$__dircolors" ]; then
		$__dircolors "$__theme"
	fi
fi

unset __theme
