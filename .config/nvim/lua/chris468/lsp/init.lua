require 'chris468.util.if-ext' ('lspconfig', function(lspconfig)

  local servers = (function()
    local settings = {}
    local server_configs_path = vim.fn.stdpath('config') .. '/lua/chris468/lsp/servers'
    for f in vim.fs.dir(server_configs_path) do
      local server = string.gsub(f, '.lua', '')
      settings[server] = require('chris468.lsp.servers.' .. server)
    end
    return settings
  end)()

  local function add_capabilities(settings)

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
    lspconfig[server].setup { add_capabilities(settings) }
  end

end)


