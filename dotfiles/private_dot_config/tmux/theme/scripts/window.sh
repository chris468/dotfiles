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
	local content="#I#W$(window_status_icon)"

	tmux set -g window-status-format "$(render_content \
		"$content" \
		"$window_foreground" \
		"$window_background" \
		"$window_separator_left" \
		"$window_separator_right")"
	tmux set -g window-status-current-format "$(render_content "$content" \
		"$window_current_foreground" \
		"#{E:@window_current_background}" \
		"$window_separator_left" \
		"$window_separator_right")"
}
