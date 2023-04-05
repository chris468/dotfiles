require 'chris468.util.if-ext' ('dap', function(_)
  local sign_text = require 'chris468.util.sign-text'
  local signs = {
    DapBreakpoint = {
      text = sign_text.breakpoint,
      texthl = 'DraculaRed',
      linehl = 'DraculaRedInverse'
    },
    DapBreakpointConditional = {
      text = sign_text.disabled_breakpoint,
    },
    DapLogPoint = {
      text = sign_text.logpoint,
      texthl = 'DraculaRed',
    },
    DapStopped = {
      text = sign_text.current_location,
      texthl = 'DraculaYellow',
    },
    DapBreakpointRejected = {
      text = sign_text.disabled_breakpoint,
      texthl = 'DraculaRed',
    },
  }

  for name, config in pairs(signs) do
    vim.fn.sign_define(name, config)
  end
end)

