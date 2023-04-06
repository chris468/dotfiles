local if_ext = require 'chris468.util.if-ext'

if_ext('nvim-cmp', function(cmp) if_ext('cmp_nvm_lsp', function(_)
  cmp.setup {
    sources = {
      { name = 'nvim_lsp' }
    }
  }
end) end)

