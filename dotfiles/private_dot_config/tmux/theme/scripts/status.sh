function configure_left_status {
	status_left="$status_left$(theme_segment \
		"@theme468-segment-$1" \
		"@theme468-status-left-separator-outer" \
		"@theme468-status-left-separator-right")"

	shift

	while [[ $# != 0 ]]; do
		status_left="$status_left$(theme_segment \
			"@theme468-segment-$1" \
			"@theme468-status-left-separator-left" \
			"@theme468-status-left-separator-right")"
		shift
	done

	tmux set -g status-left "$status_left"
}

function configure_right_status {
	status_right=
	while [[ $# != 1 ]]; do
		status_right="$status_right$(theme_segment \
			"@theme468-segment-$1" \
			"@theme468-status-right-separator-left" \
			"@theme468-status-right-separator-right")"
		shift
	done

	status_right="$status_right$(theme_segment \
		"@theme468-segment-$1" \
		"@theme468-status-right-separator-left" \
		"@theme468-status-right-separator-outer")"

	tmux set -g status-right "$status_right"
}
