local M = {}

function M.setup(_)
	hl.env("XCURSOR_SIZE", "24")

	hl.config({
		ecosystem = {
			no_update_news = true,
			no_donation_nag = true,
		},

		general = {
			gaps_in = 5,
			gaps_out = 20,

			border_size = 2,

			col = {
				active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
				inactive_border = "rgba(595959aa)",
			},

			allow_tearing = false,

			layout = "dwindle",
		},

		decoration = {
			rounding = 10,
			rounding_power = 2,

			active_opacity = 1.0,
			inactive_opacity = 1.0,

			shadow = {
				enabled = true,
				range = 4,
				render_power = 3,
				color = 0xee1a1a1a,
			},

			blur = {
				enabled = true,
				size = 3,
				passes = 1,
				vibrancy = 0.1696,
			},
		},

		animations = {
			enabled = true,
		},

		dwindle = {
			preserve_split = true,
		},

		master = {
			new_status = "master",
		},

		misc = {
			force_default_wallpaper = -1,
		},

		input = {
			kb_layout = "us",
			kb_variant = "",
			kb_model = "",
			kb_options = "",
			kb_rules = "",

			follow_mouse = 1,

			sensitivity = 0,

			touchpad = {
				natural_scroll = true,
			},
		},
	})

	hl.curve("myBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })

	hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "myBezier" })
	hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
	hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
	hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
	hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
	hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })
end

return setmetatable(M, {
	__call = function(_, opts)
		M.setup(opts)
	end,
})
