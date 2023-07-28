local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

local capabilities = cmp_nvim_lsp.default_capabilities()

lspconfig.lua_ls.setup({
	capabilities = capabilities,
	settings = {
		Lua = {
			workspace = {
				checkThirdParty = false,
			},
		},
	},
})

vim.api.nvim_create_autocmd("BufWritePre", {
	buffer = buffer,
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})
