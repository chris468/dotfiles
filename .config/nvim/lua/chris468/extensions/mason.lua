local if_ext = require 'chris468.util.if-ext'
local require_all = require 'chris468.util.require-all'

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

    local configs = require_all 'chris468.dap'

    mason_nvim_dap.setup {
      ensure_installed = {
        'python',
        'coreclr',
        'bash',
      },
      automatic_setup = {
        adapters = function(default)
          for adapter, config in pairs(configs) do
            if config.adapter then
              default[adapter] = config.adapter(default[adapter])
            end
          end
          return default
        end,
      },
    }

    mason_nvim_dap.setup_handlers {}

  end)

end)
