#!/usr/bin/env bash

script_path="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
source "$script_path/util.sh"
source "$script_path/segment.sh"
source "$script_path/window.sh"
source "$script_path/status.sh"

tmux set -g status-style "fg=$(get_option @theme468-status-foreground),bg=$(get_option @theme468-status-background)"

configure_left_status $(get_option @theme468-status-left-modules)
configure_right_status $(get_option @theme468-status-right-modules)
configure_window_status
