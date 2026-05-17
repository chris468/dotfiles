local M = {}

function M.setup(_)
	hl.monitor({
		output = "",
		mode = "preferred",
		position = "auto",
		scale = "auto",
	})

	hl.device({
		name = "epic-mouse-v1",
		sensitivity = -0.5,
	})
end

return setmetatable(M, {
	__call = function(_, opts)
		M.setup(opts)
	end,
})
