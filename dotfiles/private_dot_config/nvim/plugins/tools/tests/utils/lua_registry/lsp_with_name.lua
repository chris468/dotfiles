local packages = require("tests.utils.lua_registry._packages")

return packages.create(packages.names.lsp_with_name.name, {
  neovim = {
    lspconfig = packages.names.lsp_with_name.tool_name,
  },
})
