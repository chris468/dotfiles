set -g escape-time 0

set-window-option -g mode-keys vi

bind -r k select-pane -U
bind -r j select-pane -D
bind -r h select-pane -L
bind -r l select-pane -R

bind -r \' select-window -l

bind Z 'last-pane ; resize-pane -Z'

unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix
