function catppuccin_mocha_colors {
	cpm_rosewater="#f5e0dc"
	cpm_flamingo="#f2cdcd"
	cpm_pink="#f5c2e7"
	cpm_mauve="#cba6f7"
	cpm_red="#f38ba8"
	cpm_maroon="#eba0ac"
	cpm_peach="#fab387"
	cpm_yellow="#f9e2af"
	cpm_green="#a6e3a1"
	cpm_teal="#94e2d5"
	cpm_sky="#89dceb"
	cpm_sapphire="#74c7ec"
	cpm_blue="#89b4fa"
	cpm_lavender="#b4befe"
	cpm_text="#cdd6f4"
	cpm_subtext1="#bac2de"
	cpm_subtext0="#a6adc8"
	cpm_overlay2="#9399b2"
	cpm_overlay1="#7f849c"
	cpm_overlay0="#6c7086"
	cpm_surface2="#585b70"
	cpm_surface1="#45475a"
	cpm_surface0="#313244"
	cpm_base="#1e1e2e"
	cpm_mantle="#181825"
	cpm_crust="#11111b"

	tmux set -g @theme468-status-foreground "$cpm_text"
	tmux set -g @theme468-status-background "$cpm_mantle"
	tmux set -g @theme468-mode-foreground "$cpm_text"
	tmux set -g @theme468-mode-background "$cpm_surface1"

	tmux set -g @theme468-window-foreground "$cpm_sky"
	tmux set -g @theme468-window-background "$cpm_surface0"
	tmux set -g @theme468-window-current-foreground "$cpm_surface0"
	tmux set -g @theme468-window-current-background "$cpm_sky"
	tmux set -g @theme468-window-current-background-suspended "$cpm_mantle"

	tmux set -g @theme468-segment-session-foreground "$cpm_mantle"
	tmux set -g @theme468-segment-session-foreground-prefix "$cpm_mantle"
	tmux set -g @theme468-segment-session-background "$cpm_blue"
	tmux set -g @theme468-segment-session-foreground-suspended "$cpm_overlay0"
	tmux set -g @theme468-segment-session-background-suspended "$cpm_mantle"
	tmux set -g @theme468-segment-session-background-prefix "$cpm_green"

	tmux set -g @theme468-segment-host-foreground "$cpm_mantle"
	tmux set -g @theme468-segment-host-foreground-prefix "$cpm_mantle"
	tmux set -g @theme468-segment-host-background "$cpm_blue"
	tmux set -g @theme468-segment-host-foreground-suspended "$cpm_overlay0"
	tmux set -g @theme468-segment-host-background-suspended "$cpm_mantle"
	tmux set -g @theme468-segment-host-background-prefix "$cpm_green"

	tmux set -g @theme468-segment-date-foreground "$cpm_blue"
	tmux set -g @theme468-segment-date-background "$cpm_surface0"

	tmux set -g @theme468-message-style-foreground "$cpm_blue"
	tmux set -g @theme468-message-style-background "$cpm_base"
	tmux set -g @theme468-message-command-style-foreground "$cpm_sky"
	tmux set -g @theme468-message-command-style-background "$cpm_base"
	tmux set -g @theme468-copy-mode-match-style-foreground "$cpm_base"
	tmux set -g @theme468-copy-mode-match-style-background "$cpm_sky"
	tmux set -g @theme468-copy-mode-current-match-style-foreground "$cpm_base"
	tmux set -g @theme468-copy-mode-current-match-style-background "$cpm_blue"
	tmux set -g @theme468-copy-mode-mark-style-foreground "$cpm_base"
	tmux set -g @theme468-copy-mode-mark-style-background "$cpm_blue"

	tmux set -g @theme468-display-panes-color "$cpm_surface0"
	tmux set -g @theme468-display-panes-active-color "$cpm_sky"
	tmux set -g @theme468-pane-border-foreground "$cpm_surface0"
	tmux set -g @theme468-pane-border-foreground-suspended "$cpm_mantle"
	tmux set -g @theme468-pane-border-background "default"
	tmux set -g @theme468-pane-active-border-foreground "$cpm_sky"
	tmux set -g @theme468-pane-active-border-foreground-suspended "$cpm_surface0"
	tmux set -g @theme468-pane-active-border-background "default"

	unset -f catppuccin_mocha_colors
} && catppuccin_mocha_colors