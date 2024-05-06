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
