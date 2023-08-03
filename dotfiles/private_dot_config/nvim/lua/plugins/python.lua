return {
	{
		"nvim-lspconfig",
		opts = function(_, opts)
			opts.servers.ruff_lsp = nil
		end,
	},
	{
		"mason.nvim",
		opts = function(_, opts)
			table.insert(opts.ensure_installed, "black")
		end,
	},
	{
		"null-ls.nvim",
		opts = function(_, opts)
			local null_ls = require("null-ls")
			table.insert(opts.sources, null_ls.builtins.formatting.black)
		end,
	},
}
