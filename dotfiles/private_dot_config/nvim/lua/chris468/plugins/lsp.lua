return {
	{
		"rafcamlet/nvim-luapad",
		cmd = {
			"Luapad",
			"LuaRun",
			"Lua",
		},
	},
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{
				"williamboman/mason-lspconfig.nvim",
				tag = "stable",
				dependencies = {
					{ "hrsh7th/cmp-nvim-lsp" },
					{ "williamboman/mason.nvim" },
					{ "hrsh7th/cmp-nvim-lsp" },
					{
						"folke/neodev.nvim", -- must be initialized before lsps"
						config = true,
						ft = "lua",
					},
				},
				opts = require("chris468.config.lsp").mason_lsp,
				config = function(_, opts)
					require("mason-lspconfig").setup(opts)
					require("mason-lspconfig").setup_handlers({
						function(server_name)
							local server = require("lspconfig")[server_name]
							local server_config = require("chris468.config.lsp").servers[server_name]

							local cmp_lsp = require("cmp_nvim_lsp")
							server_config.capabilities = cmp_lsp.default_capabilities()

							server.setup(server_config)
						end,
					})
				end,
			},
		},
	},
	{
		"jose-elias-alvarez/null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			sources = {},
		},
		dependencies = {
			{
				"jayp0521/mason-null-ls.nvim",
				dependencies = {
					"williamboman/mason.nvim",
				},
				opts = {
					ensure_installed = {
						"stylua",
					},
					automatic_installation = false,
					handlers = {},
				},
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		build = ":TSUpdate",
		opts = {
			ensure_installed = {
				"lua",
			},
			sync_install = false,
			auto_install = true,
			highlight = { enable = true },
		},
		main = "nvim-treesitter.configs",
	},
}
