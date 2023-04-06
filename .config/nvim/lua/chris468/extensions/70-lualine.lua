require('chris468.util.if-ext')('lualine', function(lualine)
  local symbols = require 'chris468.util.symbols'
  lualine.setup {
    theme = 'dracula',
    sections = {
      lualine_b = {
        {
          'branch',
          fmt = function(branch)
            return branch
              :gsub('^users/cpawling', 'u')
              :gsub('^users', 'u')
          end,
        },
        'diff',
        { 'diagnostics',
          sections = { 'error', 'warn' },
          symbols = { error = symbols.error, warn = symbols.warning, },
        },
      },
      lualine_x = {
        'encoding',
        { 'fileformat', symbols = { unix = 'unix', mac = 'mac', dos = 'dos' } },
        'filetype'},
    },
  }
end)
