return {
	{
		"hrsh7th/cmp-nvim-lsp",
		lazy = true,
	},
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-cmdline" },
			{ "hrsh7th/cmp-nvim-lua" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-nvim-lsp-signature-help" },
			{ "hrsh7th/cmp-path" },
			{ "L3MON4D3/LuaSnip" },
			{ "rafamadriz/friendly-snippets" },
			{ "saadparwaiz1/cmp_luasnip" },
		},
		opts = function()
			return require("chris468.config.cmp")
		end,
		config = function(_, opts)
			local cmp = require("cmp")
			cmp.setup(opts.core)

			cmp.setup.cmdline("/", opts.search)

			cmp.setup.cmdline(":", opts.ex)

			vim.api.nvim_create_autocmd("CmdwinEnter", {
				group = vim.api.nvim_create_augroup("chris468_cmp", {}),
				callback = function(_)
					cmp.abort()
				end,
			})
		end,
	},
}
