#!/usr/bin/env bash

script_path="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
modules_path="$script_path/modules"
colors_path="$script_path/colors"

theme=$(tmux show-option -gv @chris468-theme)
source "$colors_path/$theme.sh"

function dim_when_suspended() {
	default="$1"
	suspended="$2"

	echo "#{?@theme468-suspended,$suspended,$default}"
}

tmux set -g status-interval 1
tmux set -g default-terminal xterm-256color
tmux set -sa terminal-overrides ",xterm*:Tc"
tmux set -g display-time 4000

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
tmux set -g @theme468-mode-foreground "$mode_foreground"
tmux set -g @theme468-mode-background "$mode_background"

tmux set -g @theme468-window "#I#W "
tmux set -g @theme468-window-foreground "$window_foreground"
tmux set -g @theme468-window-background "$window_background"
tmux set -g @theme468-window-current-foreground "$window_current_foreground"
tmux set -g @theme468-window-current-background \
	"$(dim_when_suspended $window_current_background $window_current_suspended_background)"

tmux set -g @theme468-segment-session "#S"
tmux set -g @theme468-segment-session-icon " "
tmux set -g @theme468-segment-session-foreground "#{?client_prefix,$status_outer_prefix_foreground,$status_outer_foreground}"
tmux set -g @theme468-segment-session-background \
	"#{?client_prefix,$status_outer_prefix_background,$(dim_when_suspended $status_outer_background $status_outer_suspended_background)}"
tmux set -g @theme468-segment-session-attr "bold"

tmux set -g @theme468-segment-host "#H"
tmux set -g @theme468-segment-host-icon " 󰒋 "
tmux set -g @theme468-segment-host-foreground "#{?client_prefix,$status_outer_prefix_foreground,$status_outer_foreground}"
tmux set -g @theme468-segment-host-background \
	"#{?client_prefix,$status_outer_prefix_background,$(dim_when_suspended $status_outer_background $status_outer_suspended_background)}"

tmux set -g @theme468-segment-host-attr "bold"

tmux set -g @theme468-segment-date "#($modules_path/date.tmux) "
tmux set -g @theme468-segment-date-icon " 󰃰 "
tmux set -g @theme468-segment-date-foreground "$status_segment_foreground"
tmux set -g @theme468-segment-date-background "$status_segment_background"

tmux set -g @theme468-status-left-modules "session"
tmux set -g @theme468-status-right-modules "date host"

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
