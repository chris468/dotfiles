set-option -g pane-border-format ""
set -g pane-border-status bottom

# color palette
# "#2e3440" # nord0
# "#3b4252" # nord1
# "#434c5e" # nord2
# "#4c566a" # nord3
# "#d8dee9" # nord4
# "#e5e9f0" # nord5
# "#eceff4" # nord6
# "#8fbcbb" # nord7
# "#88c0d0" # nord8
# "#81a1c1" # nord9
# "#5e81ac" # nord10
# "#bf616a" # nord11
# "#d08770" # nord12
# "#ebcb8b" # nord13
# "#a3be8c" # nord14
# "#b48ead" # nord15

set-option -g '@status_foreground' "#d8dee9" # nord4
set-option -g '@status_background' "#3b4252" # nord1
set-option -g '@status_style' "fg=#{@status_foreground},bg=#{@status_background}"

set-option -g '@status_outer_segment_foreground' "#2e3440" # nord0
set-option -g '@status_outer_segment_background' "#88c0d0" # nord8
set-option -g '@status_outer_segment_prefix_foreground' "#2e3440" # nord0
set-option -g '@status_outer_segment_prefix_background' "#d8dee9" # nord4

set-option -g '@status_segment_foreground' "#88c0d0" # nord8
set-option -g '@status_segment_background' "#4c566a" # nord3
set-option -g '@status_segment_current_foreground' "#d8dee9" # nord4
set-option -g '@status_segment_current_background' "#5e81ac" # nord10

set-option -g '@status_outer_segment_style' "fg=#{@status_outer_segment_foreground},bg=#{@status_outer_segment_background},bold"
set-option -g '@status_outer_segment_separator_style' "fg=#{@status_outer_segment_background},bg=#{@status_background},nobold"
set-option -g '@status_outer_segment_prefix_style' "fg=#{@status_outer_segment_prefix_foreground}#,bg=#{@status_outer_segment_prefix_background}#,bold"
set-option -g '@status_outer_segment_prefix_separator_style' "fg=#{@status_outer_segment_prefix_background},bg=#{@status_background},nobold"
set-option -g '@status_segment_style' "fg=#{@status_segment_foreground},bg=#{@status_segment_background}"
set-option -g '@status_segment_separator_style' "fg=#{@status_segment_background},bg=#{@status_background}"
set-option -g '@status_segment_current_style' "fg=#{@status_segment_current_foreground},bg=#{@status_segment_current_background}"
set-option -g '@status_segment_current_separator_style' "fg=#{@status_segment_current_background},bg=#{@status_background}"

set-option -g pane-border-style "fg=#{@status_segment_background},bg=default"
set-option -g pane-active-border-style "fg=#{@status_segment_current_background},bg=default"

# options didn't work for setting pane colours
set-option -g display-panes-colour "#4c566a" # nord3
set-option -g display-panes-active-colour "#5e81ac" # nord10

set-option -g message-style fg="#88c0d0",bg="#2e3440" # nord8, nord0
set-option -g message-command-style fg="#5e81ac",bg="#2e3440"  # nord10, nord0
set-option -g copy-mode-match-style fg="#2e3440",bg="#5e81ac"  # nord0, nord10
set-option -g copy-mode-current-match-style fg="#2e3440",bg="#88c0d0"  # nord0, nord8
set-option -g copy-mode-mark-style fg="#2e3440",bg="#88c0d0"  # nord0, nord8
set-option -g mode-style fg="#2e3440",bg="#5e81ac"  # nord0, nord10

set -g status-interval 1

set-option -g status-style "#{E:@status_style}"
set -g status-left "#{?client_prefix,#[#{E:@status_outer_segment_prefix_style}],#[#{E:@status_outer_segment_style}]} #S #{?client_prefix,#[#{E:@status_outer_segment_prefix_separator_style}],#[#{E:@status_outer_segment_separator_style}]}"
set -g status-right "#[#{E:@status_segment_separator_style}]#[#{E:@status_segment_style}] #(date -u +'%%H:%%M %%m/%%d') #[#{E:@status_segment_separator_style}]#[#{E:@status_segment_style}] #(date +'%%H:%%M%%z %%m/%%d') #[#{E:@status_segment_separator_style}]#{?client_prefix,#[#{E:@status_outer_segment_prefix_separator_style}],#[#{E:@status_outer_segment_separator_style}]}#{?client_prefix,#[#{E:@status_outer_segment_prefix_style}],#[#{E:@status_outer_segment_style}]} #H "

set -g window-status-format "#[#{E:@status_segment_separator_style}]#[#{E:@status_segment_style}]#{?window_marked_flag,, }#I#W#{?window_last_flag,󰕍, }#[#{E:@status_segment_separator_style}]"
set -g window-status-current-format "#[#{E:@status_segment_current_separator_style}]#[#{E:@status_segment_current_style}]#{?window_marked_flag,, }#I#W #[#{E:@status_segment_current_separator_style}]"
set -g window-status-separator ""


set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'MunifTanjim/tmux-suspend'

set -g status-right-length 60

# nord10, nord8
set -g @suspend_on_resume_command "tmux \
  set-option -q '@status_segment_current_background' '#5e81ac' \\; \
  set-option -q '@status_outer_segment_background' '#88c0d0'"

# nord3, nord3
set -g @suspend_on_suspend_command "tmux \
  set-option -q '@status_segment_current_background' '#4c566a' \\; \
  set-option -q '@status_outer_segment_background' '#4c566a'"


