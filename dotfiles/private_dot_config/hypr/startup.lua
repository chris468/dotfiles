local M = {}

function M.setup(_)
	hl.on("hyprland.start", function()
		hl.exec_cmd("waybar")
	end)
end

return setmetatable(M, {
	__call = function(_, opts)
		M.setup(opts)
	end,
})
