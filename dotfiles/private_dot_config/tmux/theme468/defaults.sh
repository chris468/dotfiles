default_foreground=white
default_background=black

default_status_foreground=white
default_status_background=black

default_segment_foreground=black
default_segment_background=green

default_window_foreground=black
default_window_background=blue
default_window_current_foreground=white
default_window_current_background=blue

default_attr=

default_status_left_separator_outer=''
default_status_left_separator_left=''
default_status_left_separator_right=''
default_status_right_separator_outer=''
default_status_right_separator_left=''
default_status_right_separator_right=''
default_window_separator_left=''
default_window_separator_right=''

default_theme_window="#I#W"

default_status_left_modules="default-left"
default_status_right_modules="default-right"

tmux set -g @theme468-segment-default-left "#S"
tmux set -g @theme468-segment-default-left-icon "S"
tmux set -g @theme468-segment-default-left-foreground black
tmux set -g @theme468-segment-default-left-background white
tmux set -g @theme468-segment-default-left-attr bold

tmux set -g @theme468-segment-default-right "#H"
tmux set -g @theme468-segment-default-right-icon "H"
tmux set -g @theme468-segment-default-right-foreground white
tmux set -g @theme468-segment-default-right-background blue
tmux set -g @theme468-segment-default-right-attr underscore
