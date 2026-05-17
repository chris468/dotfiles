local M = {}

function M.setup(_)
	hl.window_rule({
		name = "suppress-maximize-events",
		match = { class = ".*" },

		suppress_event = "maximize",
	})

	hl.window_rule({
		name = "fix-xwayland-drags",
		match = {
			class = "^$",
			title = "^$",
			xwayland = true,
			float = true,
			fullscreen = false,
			pin = false,
		},

		no_focus = true,
	})

	hl.window_rule({
		name = "move-hyprland-run",
		match = { class = "hyprland-run" },

		move = "20 monitor_h-120",
		float = true,
	})
end

return setmetatable(M, {
	__call = function(_, opts)
		M.setup(opts)
	end,
})
