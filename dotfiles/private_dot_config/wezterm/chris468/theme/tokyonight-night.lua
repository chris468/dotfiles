local inactive_bg = "#292e42"
local active_bg = "#1a1b26"

local active_fg = "#c0caf5"
local inactive_fg = "#565f89"

return function(config)
	config.color_scheme = "tokyonight_night"
	config.colors = {
		tab_bar = {
			active_tab = {
				bg_color = active_bg,
				fg_color = active_fg,
			},
			inactive_tab = {
				bg_color = inactive_bg,
				fg_color = inactive_fg,
			},
			inactive_tab_hover = {
				bg_color = inactive_bg,
				fg_color = active_fg,
			},
			new_tab = {
				fg_color = inactive_fg,
				bg_color = inactive_bg,
			},
			new_tab_hover = {
				fg_color = active_fg,
				bg_color = active_bg,
			},
			background = inactive_bg,
		},
	}

	config.window_frame = {
		active_titlebar_bg = inactive_bg,
	}
end
