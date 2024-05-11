#!/usr/bin/env bash

script_path="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
source "$script_path/util.sh"
source "$script_path/defaults.sh"
source "$script_path/segment.sh"
source "$script_path/window.sh"
source "$script_path/status.sh"

tmux set -g window-status-separator ""
tmux set -g status-right-length 60
tmux set -g pane-border-format ""
tmux set -g pane-border-status bottom

tmux set -g status-style "fg=$(
	get_option @theme468-status-foreground "$default_status_foreground"
),bg=$(
	get_option @theme468-status-background "$default_status_background"
)"

tmux set -g mode-style "fg=$(
	get_option @theme468-mode-foreground "$default_foreground"
),bg=$(
	get_option @theme468-mode-background "$default_background"
)"

tmux set -g message-style "fg=$(
	get_option @theme468-message-style-foreground "$default_foreground"
),bg=$(
	get_option @theme468-message-style-background "$default_background"
)"

tmux set -g message-command-style "fg=$(
	get_option @theme468-message-command-style-foreground "$default_foreground"
),bg=$(
	get_option @theme468-message-command-style-background "$default_background"
)"

tmux set -g copy-mode-match-style "fg=$(
	get_option @theme468-copy-mode-match-style-foreground "$default_foreground"
),bg=$(
	get_option @theme468-copy-mode-match-style-background "$default_background"
)"

tmux set -g copy-mode-current-match-style "fg=$(
	get_option @theme468-copy-mode-current-match-style-foreground "$default_foreground"
),bg=$(
	get_option @theme468-copy-mode-current-match-style-background "$default_background"
)"

tmux set -g copy-mode-mark-style "fg=$(
	get_option @theme468-copy-mode-mark-style-foreground "$default_foreground"
),bg=$(
	get_option @theme468-copy-mode-mark-style-background "$default_background"
)"

tmux set -g display-panes-colour "$(get_option @theme468-display-panes-color "$default_background")"
tmux set -g display-panes-active-colour "$(get_option @theme468-display-panes-active-color "$default_background_color")"

bfg="$(get_option @theme468-pane-border-foreground "$default_foreground")"
tmux set -g pane-border-style "fg=$(
	dynamic_color "$bfg" "$bfg" "$(get_option @theme468-pane-border-foreground-suspended "$bfg" "$default_foreground")"
),bg=$(
	get_option @theme468-pane-border-background "$default_background"
)"

abfg="$(get_option @theme468-pane-active-border-foreground "$default_foreground")"

tmux set -g pane-active-border-style "fg=$(
	dynamic_color "$abfg" "$abfg" "$(get_option @theme468-pane-active-border-foreground-suspended "$abfg" "$default_foreground")"
),bg=$(
	get_option @theme468-pane-active-border-background "$default_background"
)"

configure_left_status
configure_right_status
configure_window_status

tmux set -g @theme468-suspended 0
tmux set -g @suspend_suspended_options "@theme468-suspended:g:1"
