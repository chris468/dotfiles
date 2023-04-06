local symbols = require 'chris468.util.symbols'

local signs = {
  DiagnosticSignWarn = {
    text = symbols.warning
  },
  DiagnosticSignInfo = {
    text = symbols.info
  },
  DiagnosticSignHint = {
    text = symbols.hint
  },
  DiagnosticSignError = {
    text = symbols.error
  }
}

local original_handler = vim.diagnostic.handlers.signs

vim.diagnostic.handlers.signs = {
  show = function(n, b, d, o)
    original_handler.show(n, b, d, o)
    vim.diagnostic.handlers.signs = original_handler

    for name, config in pairs(signs) do
      vim.fn.sign_define(name, config)
    end
  end,
  hide = original_handler.hide
}

local create_autocmds = require 'chris468.util.create-autocmds'
create_autocmds({
  show_diagnostic = {
    {
      event = 'CursorHold',
      opts = {
        pattern = '*',
        callback = vim.diagnostic.open_float
      }
    }
  }
})
