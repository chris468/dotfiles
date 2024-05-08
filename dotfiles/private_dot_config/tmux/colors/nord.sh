function nord_colors {
	nord0="#2e3440"
	nord1="#3b4252"
	nord2="#434c5e"
	nord3="#4c566a"
	nord4="#d8dee9"
	nord5="#e5e9f0"
	nord6="#eceff4"
	nord7="#8fbcbb"
	nord8="#88c0d0"
	nord9="#81a1c1"
	nord10="#5e81ac"
	nord11="#bf616a"
	nord12="#d08770"
	nord13="#ebcb8b"
	nord14="#a3be8c"
	nord15="#b48ead"

	status_foreground=$nord4
	status_background=$nord1

	status_segment_foreground=$nord8
	status_segment_background=$nord3
	status_outer_foreground=$nord0
	status_outer_background=$nord8
	status_outer_suspended_background=$nord3

	status_outer_prefix_foreground=$nord0
	status_outer_prefix_background=$nord4

	window_foreground=$nord8
	window_background=$nord3
	window_current_foreground=$nord4
	window_current_background=$nord10
	window_current_suspended_background=$nord3

	display_panes_color=$nord3
	display_panes_active_color=$nord10

	message_style_foreground=$nord8
	message_style_background=$nord0
	message_command_style_foreground=$nord10
	message_command_style_background=$nord0

	copy_mode_match_style_foreground=$nord0
	copy_mode_match_style_background=$nord10
	copy_mode_current_match_style_foreground=$nord0
	copy_mode_current_match_style_background=$nord8
	copy_mode_mark_style_foreground=$nord0
	copy_mode_mark_style_background=$nord8

	mode_foreground=$nord0
	mode_background=$nord10

	tmux set -g @theme468-mode-foreground "$mode_foreground"
	tmux set -g @theme468-mode-background "$mode_background"
	tmux set -g @theme468-status-foreground "$status_foreground"
	tmux set -g @theme468-status-background "$status_background"
	tmux set -g @theme468-mode-foreground "$mode_foreground"
	tmux set -g @theme468-mode-background "$mode_background"

	tmux set -g @theme468-window-foreground "$window_foreground"
	tmux set -g @theme468-window-background "$window_background"
	tmux set -g @theme468-window-current-foreground "$window_current_foreground"
	tmux set -g @theme468-window-current-background \
		"$(dim_when_suspended $window_current_background $window_current_suspended_background)"

	tmux set -g @theme468-segment-session-foreground "$status_outer_prefix_foreground"
	tmux set -g @theme468-segment-session-foreground-prefix "$status_outer_foreground"
	tmux set -g @theme468-segment-session-background "$status_outer_background"
	tmux set -g @theme468-segment-session-background-suspended "$status_outer_suspended_background"
	tmux set -g @theme468-segment-session-background-prefix "$status_outer_prefix_background"

	tmux set -g @theme468-segment-host-foreground "$status_outer_foreground"
	tmux set -g @theme468-segment-host-foreground-prefix "$status_outer_prefix_foreground"
	tmux set -g @theme468-segment-host-background "$status_outer_background"
	tmux set -g @theme468-segment-host-background-suspended "$status_outer_suspended_background"
	tmux set -g @theme468-segment-host-background-prefix "$status_outer_prefix_background"

	tmux set -g @theme468-segment-date "#($modules_path/date.tmux) "
	tmux set -g @theme468-segment-date-icon " 󰃰 "
	tmux set -g @theme468-segment-date-foreground "$status_segment_foreground"
	tmux set -g @theme468-segment-date-background "$status_segment_background"

	tmux set -g @theme468-message-style-foreground "$message_style_foreground"
	tmux set -g @theme468-message-style-background "$message_style_background"
	tmux set -g @theme468-message-command-style-foreground "$message_command_style_foreground"
	tmux set -g @theme468-message-command-style-background "$message_command_style_background"
	tmux set -g @theme468-copy-mode-match-style-foreground "$copy_mode_match_style_foreground"
	tmux set -g @theme468-copy-mode-match-style-background "$copy_mode_match_style_background"
	tmux set -g @theme468-copy-mode-current-match-style-foreground "$copy_mode_current_match_style_foreground"
	tmux set -g @theme468-copy-mode-current-match-style-background "$copy_mode_current_match_style_background"
	tmux set -g @theme468-copy-mode-mark-style-foreground "$copy_mode_mark_style_foreground"
	tmux set -g @theme468-copy-mode-mark-style-background "$copy_mode_mark_style_background"

	tmux set -g @theme468-display-panes-color "$display_panes_color"
	tmux set -g @theme468-display-panes-active-color "$display_panes_active_color"
	tmux set -g @theme468-pane-border-foreground "$window_background"
	tmux set -g @theme468-pane-border-background "default"
	tmux set -g @theme468-pane-active-border-foreground \
		"$(dim_when_suspended $window_current_background $window_current_suspended_background)"
	tmux set -g @theme468-pane-active-border-background "default"

	unset -f nord_colors
} && nord_colors
