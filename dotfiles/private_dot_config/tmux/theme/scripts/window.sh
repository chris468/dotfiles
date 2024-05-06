function window_status_icon {
	local window_icon_last="󰖰"
	local window_icon_current="󰖯"
	local window_icon_zoom="󰁌"
	local window_icon_mark="󰃀"
	local window_icon_silent="󰂛"
	local window_icon_activity="󱅫"
	local window_icon_bell="󰂞"

	local icon="#{?window_activity_flag, $window_icon_activity,"
	icon="$icon#{?window_bell_flag, $window_icon_bell,"
	icon="$icon#{?window_silence_flag, $window_icon_silent,"
	icon="$icon#{?window_active, $window_icon_current,"
	icon="$icon#{?window_last_flag, $window_icon_last,"
	icon="$icon#{?window_marked_flag, $window_icon_mark,"
	icon="$icon#{?window_zoomed_flag, $window_icon_zoom, }"
	icon="$icon}}}}}}"

	echo $icon
}

function configure_window_status {
	tmux set -g window-status-format "$(theme_segment \
		"@theme468-window" \
		"@theme468-window-separator-left" \
		"@theme468-window-separator-right")"
	tmux set -g window-status-current-format "$(theme_segment \
		"@theme468-window-current" \
		"@theme468-window-separator-left" \
		"@theme468-window-separator-right" \
		"@theme468-window")"
}
