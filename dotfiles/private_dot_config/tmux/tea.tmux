set -ga @tpm_plugins " 2kabhishek/tmux-tea"
set -g @tea-alt-bind false
set -g @tea-find-path "$HOME"

bind -T prefix s run-shell 'tea'
bind-key -T prefix S choose-tree -Zs
