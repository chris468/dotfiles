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

  local create_autocmds = require 'chris468.util.create-autocmds'
  create_autocmds({
    load_launchjs = {
      {
        event = 'BufWritePost',
        opts = {
          pattern = 'launch.json',
          callback = function() require('chris468.dap.launch').load_configs(dap, true) end,
        }
      }
    }
  })

end)

