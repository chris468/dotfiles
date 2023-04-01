local if_ext = require 'chris468.util.if-ext'

if_ext('mason', function(mason)

  mason.setup()

  if_ext('mason-lspconfig', function(mason_lspconfig)
    mason_lspconfig.setup({
      ensure_installed = {
        "pyright",
        "lua_ls",
        "omnisharp",
      }
    })
  end)

end)

