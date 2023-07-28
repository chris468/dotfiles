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
					"williamboman/mason.nvim",
					{
						"folke/neodev.nvim", -- must be initialized before lsps"
						config = true,
						ft = "lua",
					},
				},
				opts = {
					ensure_installed = {
						"lua_ls",
					},
				},
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
