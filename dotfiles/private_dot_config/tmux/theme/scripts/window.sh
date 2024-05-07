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
	tmux set -g window-status-format "$(segment \
		"$(get_option @theme468-window-foreground "$default_window_foreground")" \
		"$(get_option @theme468-window-background "$default_window_background")" \
		"$(get_option @theme468-window-attr "$default_attr")" \
		"$(get_option @theme468-window-separator-left "$default_window_separator_left")" \
		"$(get_option @theme468-window-separator-right "$default_window_separator_right")" \
		"$(window_status_icon) " \
		"$(get_option @theme468-window "$default_theme_window")")"

	tmux set -g window-status-current-format "$(segment \
		"$(get_option \
			@theme468-window-current-foreground \
			@theme468-window-foreground \
			"$default_window_current_foreground" \
			"$default_window_foreground")" \
		"$(get_option \
			@theme468-window-current-background \
			@theme468-window-background \
			"$default_window_current_background" \
			"$default_window_background")" \
		"$(get_option @theme468-window-current-attr @theme468-window-attr "$default_attr")" \
		"$(get_option @theme468-window-current-separator-left @theme468-window-separator-left "$default_window_separator_left")" \
		"$(get_option @theme468-window-current-separator-right @theme468-window-separator-right "$default_window_separator_right")" \
		"$(window_status_icon) " \
		"$(get_option @theme468-window "$default_theme_window")")"
}
