local wezterm = require("wezterm")

return function(config)
	config.color_scheme = "catppuccin-mocha"

	local colors = wezterm.color.get_builtin_schemes()["catppuccin-mocha"]

	local catppuccin = {
		base = "#1e1e2e",
		crust = "#11111b",
		text = "#cdd6f4",
		surface0 = "#313244",
		teal = "#94e2d5",
	}

	config.window_frame = {
		active_titlebar_bg = catppuccin.surface0,
	}

	config.colors = {
		tab_bar = {
			active_tab = {
				bg_color = catppuccin.base,
				fg_color = catppuccin.teal,
				intensity = "Bold",
				italic = true,
			},
			inactive_tab = {
				bg_color = catppuccin.surface0,
				fg_color = catppuccin.text,
				intensity = "Half",
				italic = false,
			},
			inactive_tab_hover = {
				bg_color = catppuccin.crust,
				fg_color = catppuccin.text,
				intensity = "Normal",
				italic = false,
			},
			new_tab = {
				bg_color = catppuccin.surface0,
				fg_color = catppuccin.text,
			},
			new_tab_hover = {
				bg_color = catppuccin.crust,
				fg_color = catppuccin.teal,
			},
		},
	}
end
