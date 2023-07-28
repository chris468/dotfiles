local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

local capabilities = cmp_nvim_lsp.default_capabilities()

local lua_ls_config = require("chris468.config.lsp")(capabilities).lua_ls
lspconfig.lua_ls.setup(lua_ls_config)
