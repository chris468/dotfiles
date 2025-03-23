set -ga @tpm_plugins " omerxx/tmux-sessionx"
set -g @sessionx-bind 's'
bind-key -T prefix S choose-tree -Zs

set -g @sessionx-filter-current 'false'
set -g @sessionx-tmuxinator-mode 'on'
set -g @sessionx-layout 'reverse'
