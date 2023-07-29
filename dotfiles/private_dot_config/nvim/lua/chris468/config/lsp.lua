local M = {}

-- map of language server name to configuration
-- optional ensure_installed boolean property controls whether the server will
-- be automatically installed by mason-lspconfig, default true. Everything else
-- is passed to the lspconfig server configuration.
M.servers = {
	lua_ls = {
		settings = {
			Lua = {
				workspace = {
					checkThirdParty = false,
				},
			},
		},
	},
}

M.mason_lsp = {
	ensure_installed = {},
}

local ensure_installed = M.mason_lsp.ensure_installed
for k, v in pairs(M.servers) do
	if v.ensure_installed == nil or v.ensure_installed then
		ensure_installed[#ensure_installed + 1] = k
		v.ensure_installed = nil
	end
end

return M
