#!/usr/bin/env bash

script_path="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)"
modules_path="$script_path/modules"
colors_path="$script_path/colors"

theme=$(tmux show-option -gv @chris468-theme)

function dim_when_suspended() {
  default="$1"
  suspended="$2"

  echo "#{?@theme468-suspended,$suspended,$default}"
}

tmux set -g status-left-length 0
tmux set -g @theme468-status-left-modules "session"
tmux set -g @theme468-status-right-modules "date host"

tmux set -g @theme468-window "#I#W "

tmux set -g @theme468-segment-session "#{=/15/…:session_name} "
tmux set -g @theme468-segment-session-icon " "
tmux set -g @theme468-segment-session-attr "bold"

tmux set -g @theme468-segment-host "#H"
tmux set -g @theme468-segment-host-icon " 󰒋 "
tmux set -g @theme468-segment-host-attr "bold"

tmux set -g @theme468-segment-date "#($modules_path/date.tmux) "
tmux set -g @theme468-segment-date-icon " 󰃰 "

tmux set -g status-interval 1
tmux set -g display-time 4000

tmux set -g @theme468-status-left-separator-outer "█"
tmux set -g @theme468-status-left-separator-left ""
tmux set -g @theme468-status-left-separator-right ""
tmux set -g @theme468-status-right-separator-outer "█"
tmux set -g @theme468-status-right-separator-left ""
tmux set -g @theme468-status-right-separator-right ""
tmux set -g @theme468-window-separator-left ""
tmux set -g @theme468-window-separator-right ""

source "$colors_path/$theme.sh"
