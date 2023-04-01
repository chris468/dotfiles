return require 'chris468.util.if-ext' ('cmp_nvim_lsp',
  function(cmp_nvim_lsp)
    return function(lspconfig)
      lspconfig.pyright.setup {
         capabilities = cmp_nvim_lsp.default_capabilities()
       }
    end
  end,
  function(_)
    return function(_) end
  end
)
