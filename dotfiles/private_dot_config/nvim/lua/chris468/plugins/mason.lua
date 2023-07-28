return {
	{
		"williamboman/mason.nvim",
		tag = "stable",
		-- build = ":MasonUpdate", -- doesn't work at build
		config = true,
		cmd = {
			"Mason",
			"MasonUpdate",
			"MasonInstall",
			"MasonUninstall",
			"MasonUninstallAll",
			"MasonLog",
		},
	},
}
