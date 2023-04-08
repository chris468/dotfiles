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

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local function create_chris468_diagnostic_buffer_augroup(args)
  local function update(a)
    local w = vim.fn.bufwinid(a.buf)
    vim.diagnostic.setloclist({ winnr = w, open = false})
  end

  update(args)

  local group = augroup('chris468_diagnostic_buffer', {clear = true})
  autocmd('CursorHold', {
    group = group,
    buffer = 0,
    callback = vim.diagnostic.open_float,
  })
  autocmd({'BufEnter', 'DiagnosticChanged'}, {
    group = group,
    buffer = 0,
    callback = update
  })
end
autocmd('BufEnter', {
  group = augroup('chris468_diagnostic', { clear = true }),
  callback = create_chris468_diagnostic_buffer_augroup
})
