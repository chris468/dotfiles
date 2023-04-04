local sign_text = require 'chris468.util.signs'

local signs = {
  DiagnosticSignWarn = {
    text = sign_text.warning
  },
  DiagnosticSignHint = {
    text = sign_text.hint
  },
  DiagnosticSignError = {
    text = sign_text.error
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
