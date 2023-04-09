local if_ext = require 'chris468.util.if-ext'
local require_all = require 'chris468.util.require-all'

if_ext('mason-nvim-dap', function(mason_nvim_dap)

  local default_handler = {
    function(source_name)
      require('mason-nvim-dap.automatic_setup')(source_name)
    end
  }
  local custom_handlers = require_all 'chris468.dap.adapters'
  local handlers = vim.tbl_extend('error', default_handler, custom_handlers)

  mason_nvim_dap.setup {
    ensure_installed = {
      'python',
      'coreclr',
      'bash',
    },
    automatic_setup = true,
    handlers = handlers,
  }

end)

