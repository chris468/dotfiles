function configure_left_status {
	local status_left=
	for i in $(seq 0 $(expr ${#status_left_modules[@]} - 1)); do
		m="${status_left_modules[$i]}"
		status_left="$status_left$(render_status_module $i "left" "$m")"
	done

	tmux set -g status-left "$status_left"
}

function configure_right_status {
	local status_right=
	local max=$(expr ${#status_right_modules[@]} - 1)
	for i in $(seq 0 $max); do
		local index=$(expr $max - $i)
		m="${status_right_modules[$i]}"
		status_right="$status_right$(render_status_module $index "right" "$m")"
	done

	tmux set -g status-right "$status_right"
}
