local function setup(_, mappings)
	local wk = require("which-key")
	wk.setup({})

	for _, mapping in ipairs(mappings) do
		wk.register(unpack(mapping))
	end
end

return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 1000
	end,
	opts = require("chris468.config.mappings"),
	config = setup,
}
