return {
	"telescope.nvim",
	dependencies = {
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
		config = function()
			require("telescope").load_extension("fzf")
		end,
	},
	opts = function(_, opts)
		local actions = require("telescope.actions")
		opts.defaults.mappings.i["<C-j>"] = actions.move_selection_next
		opts.defaults.mappings.n["<C-j>"] = actions.move_selection_next
		opts.defaults.mappings.i["<C-k>"] = actions.move_selection_previous
		opts.defaults.mappings.n["<C-k>"] = actions.move_selection_previous
	end,
}
