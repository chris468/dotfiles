#!/usr/bin/env bash

theme_path="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
modules_path="$theme_path/modules"
colors_path="$theme_path/colors"
scripts_path="$theme_path/scripts"

theme=$(tmux show-option -gv @chris468-theme)

source "$colors_path/$theme.sh"
source "$scripts_path/util.sh"
source "$scripts_path/segment.sh"
source "$scripts_path/render.sh"
source "$scripts_path/status.sh"
source "$scripts_path/window.sh"

status_left_separator_outer="█"
status_left_separator_left=""
status_left_separator_right=""

status_right_separator_outer=""
status_right_separator_left=""
status_right_separator_right=""

window_separator_left=""
window_separator_right=""

tmux set -g @status_outer_background "$status_outer_background"
tmux set -g @window_current_background "$window_current_background"

tmux set -g @theme468-status-left-separator-outer "█"
tmux set -g @theme468-status-left-separator-left ""
tmux set -g @theme468-status-left-separator-right ""
tmux set -g @theme468-status-right-separator-outer "█"
tmux set -g @theme468-status-right-separator-left ""
tmux set -g @theme468-status-right-separator-right ""
tmux set -g @theme468-window-separator-left ""
tmux set -g @theme468-window-separator-right ""

tmux set -g @theme468-status-foreground "$status_foreground"
tmux set -g @theme468-status-background "$status_background"

tmux set -g @theme468-window "#I#W"
tmux set -g @theme468-window-icon "$(window_status_icon)"
tmux set -g @theme468-window-foreground "$window_foreground"
tmux set -g @theme468-window-background "$window_background"
tmux set -g @theme468-window-current-foreground "$window_current_foreground"
tmux set -g @theme468-window-current-background "#{E:@window_current_background}"

tmux set -g @theme468-segment-session "#S"
tmux set -g @theme468-segment-session-icon ""
tmux set -g @theme468-segment-session-foreground "#{?client_prefix,$status_outer_prefix_foreground,$status_outer_foreground}"
tmux set -g @theme468-segment-session-background "#{?client_prefix,$status_outer_prefix_background,$status_outer_background}"

tmux set -g @theme468-segment-host "#H"
tmux set -g @theme468-segment-host-icon "󰒋"
tmux set -g @theme468-segment-host-foreground "#{?client_prefix,$status_outer_prefix_foreground,$status_outer_foreground}"
tmux set -g @theme468-segment-host-background "#{?client_prefix,$status_outer_prefix_background,$status_outer_background}"

tmux set -g @theme468-segment-date "#($modules_path/date.tmux)"
tmux set -g @theme468-segment-date-icon "󰃰"
tmux set -g @theme468-segment-date-foreground "$status_segment_foreground"
tmux set -g @theme468-segment-date-background "$status_segment_background"

tmux set -g @theme468-status-left-modules "session"
tmux set -g @theme468-status-right-modules "date host"

tmux set -g status-interval 1
tmux set -g default-terminal xterm-256color
tmux set -sa terminal-overrides ",xterm*:Tc"
tmux set -g display-time 4000

tmux set -g window-status-separator ""
tmux set -g status-right-length 60
tmux set -g pane-border-format ""
tmux set -g pane-border-status bottom

tmux set -g status-style "fg=$status_foreground,bg=$status_background"
tmux set -g message-style "fg=$message_style_foreground,bg=$message_style_background"
tmux set -g message-command-style "fg=$message_command_style_foreground,bg=$message_command_style_background"
tmux set -g copy-mode-match-style "fg=$copy_mode_match_style_foreground,bg=$copy_mode_match_style_background"
tmux set -g copy-mode-current-match-style "fg=$copy_mode_current_match_style_foreground,bg=$copy_mode_current_match_style_background"
tmux set -g copy-mode-mark-style "fg=$copy_mode_mark_style_foreground,bg=$copy_mode_mark_style_background"
tmux set -g mode-style "fg=$mode_style_foreground,bg=$mode_style_background"
tmux set -g display-panes-colour "$display_panes_color"
tmux set -g display-panes-active-colour "$display_panes_active_color"
tmux set -g pane-border-style "fg=$window_background,bg=default"
tmux set -g pane-active-border-style "fg=#{E:@window_current_background},bg=default"

tmux set -g @suspend_on_resume_command "tmux \
  set-option -q '@window_current_background' '$window_current_background' \\; \
  set-option -q '@status_outer_background' '$status_outer_background'"

tmux set -g @suspend_on_suspend_command "tmux \
  set-option -q '@window_current_background' '$window_current_suspended_background' \\; \
  set-option -q '@status_outer_background' '$status_outer_suspended_background'"

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
configure_left_status $(tmux show-option -gv @theme468-status-left-modules)

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

configure_right_status $(tmux show-option -gv @theme468-status-right-modules)

tmux set -g window-status-format "$(theme_segment \
	"@theme468-window" \
	"@theme468-window-separator-left" \
	"@theme468-window-separator-right")"
tmux set -g window-status-current-format "$(theme_segment \
	"@theme468-window-current" \
	"@theme468-window-separator-left" \
	"@theme468-window-separator-right" \
	"@theme468-window")"
