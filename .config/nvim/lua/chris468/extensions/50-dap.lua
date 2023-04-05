require 'chris468.util.if-ext' ('dap', function(dap)
  local symbols = require 'chris468.util.symbols'
  local signs = {
    DapBreakpoint = {
      text = symbols.breakpoint,
      texthl = 'DraculaRed',
      linehl = 'DraculaRedInverse'
    },
    DapBreakpointConditional = {
      text = symbols.disabled_breakpoint,
    },
    DapLogPoint = {
      text = symbols.logpoint,
      texthl = 'DraculaRed',
    },
    DapStopped = {
      text = symbols.current_location,
      texthl = 'DraculaYellow',
    },
    DapBreakpointRejected = {
      text = symbols.disabled_breakpoint,
      texthl = 'DraculaRed',
    },
  }

  for name, config in pairs(signs) do
    vim.fn.sign_define(name, config)
  end


end)

