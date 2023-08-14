return function(config)
	config.window_frame = {
		active_titlebar_bg = "#3b4252",
		inactive_titlebar_bg = "#3b4252",
	}

	config.colors = {
		tab_bar = {
			active_tab = {
				bg_color = "#2e3440",
				fg_color = "#eceff4",
				intensity = "Bold",
				italic = true,
			},
			inactive_tab = {
				bg_color = "#3b4252",
				fg_color = "#5e81ac",
				intensity = "Half",
				italic = false,
			},
			inactive_tab_hover = {
				bg_color = "#3b4252",
				fg_color = "#8fbcbb",
				intensity = "Normal",
				italic = false,
			},
			new_tab = {
				bg_color = "#3b4252",
				fg_color = "#5e81ac",
			},
			new_tab_hover = {
				bg_color = "#3b4252",
				fg_color = "#8fbcbb",
			},
		},
	}
end
