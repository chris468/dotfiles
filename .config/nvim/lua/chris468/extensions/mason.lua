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

  if_ext('mason-nvim-dap', function(mason_nvim_dap)

    mason_nvim_dap.setup {
      ensure_installed = {
        'python',
        'coreclr',
        'bash',
      },
      automatic_setup = true,
    }

    mason_nvim_dap.setup_handlers {}

  end)

end)
