return function(_)
  local dap = require 'dap'

  local command_typo = vim.fn.exepath('debugpy-adapter')
  local command = (command_typo and command_typo ~= '') and command_typo or vim.fn.exepath('debugy-adapter')

  dap.adapters.python = {
    type = 'executable',
    command = command
  }

  dap.configurations.python = {
    {
      name = "Python: Launch file",
      program = "${file}",
      request = "launch",
      type = "python"
    }
  }
end
