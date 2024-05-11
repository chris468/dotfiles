function _configure_status {
	local option="$1"
	local modules="$2"
	local initial_left="$3"
	local remaining_left="$4"
	local initial_right="$5"
	local final_right="$6"

	set -- $modules
	local left="$initial_left"
	local right="$initial_right"
	local status=
	while [[ $# != 0 ]]; do
		[[ $# != 1 ]] || right="$final_right"

		local fg="$(dynamic_color \
			"$(get_option @theme468-segment-$1-foreground "$default_segment_foreground")" \
			"$(get_option @theme468-segment-$1-foreground-prefix)" \
			"$(get_option @theme468-segment-$1-foreground-suspended)")"

		local bg="$(dynamic_color \
			"$(get_option @theme468-segment-$1-background "$default_segment_background")" \
			"$(get_option @theme468-segment-$1-background-prefix)" \
			"$(get_option @theme468-segment-$1-background-suspended)")"

		status="$status$(segment \
			"$fg" \
			"$bg" \
			"$(get_option @theme468-segment-$1-attr "$default_attr")" \
			"$left" \
			"$right" \
			"$(get_option @theme468-segment-$1-icon "$default_icon")" \
			"$(get_option @theme468-segment-$1)")"

		left="$remaining_left"
		shift
	done

	tmux set -g "$option" "$status"
}

function configure_left_status {
	local initial_left="$(get_option \
		@theme468-status-left-separator-outer \
		@theme468-status-left-separator-left \
		"$default_status_left_separator_outer")"
	local remaining_left="$(get_option \
		@theme468-status-left-separator-left \
		"$default_status_left_separator_left")"
	local right="$(get_option \
		@theme468-status-left-separator-right \
		"$default_status_left_separator_right")"

	_configure_status \
		status-left \
		"$(get_option @theme468-status-left-modules "$default_status_left_modules")" \
		"$initial_left" \
		"$remaining_left" \
		"$right" \
		"$right"
}

function configure_right_status {
	local initial_right="$(get_option \
		@theme468-status-right-separator-right \
		"$default_status_right_separator_right")"
	local final_right="$(get_option \
		@theme468-status-right-separator-outer \
		@theme468-status-right-separator-right \
		"$default_status_right_separator_outer")"
	local left="$(get_option \
		@theme468-status-right-separator-left \
		"$default_status_right_separator_left")"

	_configure_status \
		status-right \
		"$(get_option @theme468-status-right-modules "$default_status_right_modules")" \
		"$left" \
		"$left" \
		"$initial_right" \
		"$final_right"
}
