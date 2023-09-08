if [ -n "$TMUX" ]; then
	__environment_updates="$(tmux show-environment | sed -E -e 's/^([^-][^=]+)=(.*)/export \1="\2"/' -e 's/^-/unset /')"

	while IFS=$'\n' read u; do
		eval $u
	done <<<"$__environment_updates"

	unset __environment_updates
fi
