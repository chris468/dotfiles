#!/usr/bin/env bash

script_path="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
source "$script_path/util.sh"
source "$script_path/defaults.sh"
source "$script_path/segment.sh"
source "$script_path/window.sh"
source "$script_path/status.sh"

tmux set -g status-style "fg=$(
	get_option @theme468-status-foreground "$default_status_foreground"
),bg=$(
	get_option @theme468-status-background "$default_status_background"
)"

configure_left_status
configure_right_status
configure_window_status

tmux set -g @theme468-suspended 0
tmux set -g @suspend_suspended_options "@theme468-suspended:g:1"
