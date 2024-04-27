function update-tmux-environment {
	if [ -n "$TMUX" ]; then
		local environment_updates="$(tmux show-environment | sed -E -e 's/^([^-][^=]+)=(.*)/export \1="\2"/' -e 's/^-/unset /')"

		while IFS=$'\n' read u; do
			eval $u
		done <<<"$environment_updates"
	fi
}

update-tmux-environment
