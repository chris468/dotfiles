local wezterm = require("wezterm")

local catppuccin = {
	base = "#1e1e2e",
	crust = "#11111b",
	text = "#cdd6f4",
	surface0 = "#313244",
	teal = "#94e2d5",
	overlay2 = "#9399b2",
}

return function(config)
	local colors = wezterm.color.get_builtin_schemes()["catppuccin-mocha"]

	colors.cursor_bg = catppuccin.overlay2
	colors.cursor_border = catppuccin.overlay2
	colors.cursor_fg = catppuccin.text
	colors.tab_bar = {
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
	}

	config.colors = colors

	config.window_frame = {
		active_titlebar_bg = catppuccin.surface0,
	}
end
