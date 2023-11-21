set-environment -g TMUX_PLUGIN_MANAGER_PATH '~/.config/tmux/plugins'

if "test ! -d ~/.config/tmux/plugins/tpm" \
   "run 'git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm && ~/.config/tmux/plugins/tpm/bin/install_plugins'"

run '~/.config/tmux/plugins/tpm/tpm'
