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

  local function config(settings)
    local s = require 'chris468.util.if-ext' ('cmp_nvim_lsp',
      function(cmp_nvim_lsp)
        return { capabilities = cmp_nvim_lsp.default_capabilities() }
      end,
      function() return {} end
    )
    s.settings = settings
    return s
  end

  for server, settings in pairs(servers) do
    lspconfig[server].setup { config(settings) }
  end

end)


