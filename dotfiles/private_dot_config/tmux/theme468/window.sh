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
	local fg_normal="$(get_option @theme468-window-foreground "$default_window_foreground")"
	local fg_prefix="$(get_option @theme468-window-foreground-prefix)"
	local fg_suspended="$(get_option @theme468-window-foreground-suspended)"
	local fg="$(dynamic_color "$fg_normal" "$fg_prefix" "$fg_suspended")"

	local bg_normal="$(get_option @theme468-window-background "$default_window_background")"
	local bg_suspended="$(get_option @theme468-window-background-suspended)"
	local bg_prefix="$(get_option @theme468-window-background-prefix)"
	local bg="$(dynamic_color "$bg_normal" "$bg_prefix" "$bg_suspended")"

	tmux set -g window-status-format "$(segment \
		"$fg" \
		"$bg" \
		"$(get_option @theme468-window-attr "$default_attr")" \
		"$(get_option @theme468-window-separator-left "$default_window_separator_left")" \
		"$(get_option @theme468-window-separator-right "$default_window_separator_right")" \
		"$(window_status_icon) " \
		"$(get_option @theme468-window "$default_theme_window")")"

	local current_fg_normal="$(get_option \
		@theme468-window-current-foreground \
		@theme468-window-foreground \
		"$default_window_current_foreground" \
		"$default_window_foreground")"
	local current_fg_suspended="$(get_option @theme468-window-current-foreground-suspended)"
	local current_fg_prefix="$(get_option @theme468-window-current-foreground-prefix)"
	local current_fg="$(dynamic_color "$current_fg_normal" "$current_fg_prefix" "$current_fg_suspended")"

	local current_bg_normal="$(get_option \
		@theme468-window-current-background \
		@theme468-window-background \
		"$default_window_current_background" \
		"$default_window_background")"
	local current_bg_suspended="$(get_option @theme468-window-current-background-suspended)"
	local current_bg_prefix="$(get_option @theme468-window-current-background-prefix)"
	local current_bg="$(dynamic_color "$current_bg_normal" "$current_bg_prefix" "$current_bg_suspended")"

	tmux set -g window-status-current-format "$(segment \
		"$current_fg" \
		"$current_bg" \
		"$(get_option @theme468-window-current-attr @theme468-window-attr "$default_attr")" \
		"$(get_option @theme468-window-current-separator-left @theme468-window-separator-left "$default_window_separator_left")" \
		"$(get_option @theme468-window-current-separator-right @theme468-window-separator-right "$default_window_separator_right")" \
		"$(window_status_icon) " \
		"$(get_option @theme468-window "$default_theme_window")")"
}
