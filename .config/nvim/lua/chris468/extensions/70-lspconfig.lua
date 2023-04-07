require 'chris468.util.if-ext' ('lspconfig', function(lspconfig)

  local require_all = require 'chris468.util.require-all'
  local servers = require_all 'chris468.lsp.servers'

  local function with_capabilities(settings)

    local s = require 'chris468.util.if-ext' ('cmp_nvim_lsp',
      function(cmp_nvim_lsp)
        return { capabilities = cmp_nvim_lsp.default_capabilities() }
      end,
      function() return {} end
    )

    for k, v in pairs(settings) do
      s[k] = v
    end

    return s
  end

  for server, settings in pairs(servers) do
    lspconfig[server].setup(with_capabilities(settings))
  end

end)


