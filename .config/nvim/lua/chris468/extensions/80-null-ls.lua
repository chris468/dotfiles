local if_ext = require 'chris468.util.if-ext'
if_ext('null-ls', function(null_ls)
  local builtins = null_ls.builtins
  local diagnostics = builtins.diagnostics
  local formatting = builtins.formatting
  null_ls.setup {
    debug = true,
    sources = {
      diagnostics.flake8,
      formatting.autopep8,
      formatting.prettier,
    }
  }
end)
