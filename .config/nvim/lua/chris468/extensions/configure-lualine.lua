local lualine = require 'lualine'
local symbols = require 'chris468.util.symbols'
lualine.setup {
  theme = 'dracula',
  extensions = { 'quickfix', 'nvim-tree', 'nvim-dap-ui', },
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
        sections = { 'error', 'warn', 'info', 'hint' },
        symbols = {
          error = symbols.error,
          warn = symbols.warning,
          info = symbols.info,
          hint = symbols.hint,
        },
      },
    },
    lualine_x = {
      'encoding',
      { 'fileformat', symbols = { unix = 'unix', mac = 'mac', dos = 'dos' } },
      'filetype'},
  },
}
