return {
	"nvim-cmp",
	opts = function(_, opts)
		local mapping = opts.mapping
		mapping["<C-j>"] = opts.mapping["<C-N>"]
		mapping["<C-k>"] = opts.mapping["<C-P>"]
	end,
}
