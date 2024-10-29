return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local lspconfig = require("lspconfig")
      local wrapped_setup = {}
      for n, _ in pairs(opts.servers) do
        opts.servers[n].mason = false
        if not opts.setup[n] then
          opts.setup[n] = function() end
        end
      end
      for name, su in pairs(opts.setup or {}) do
        local original_setup = opts.setup[name]
        wrapped_setup[name] = function(n, o)
          local map = require("mason-lspconfig.mappings.server").lspconfig_to_package
          local desc = "setup " .. n
          local package_name = map[n]
          if package_name then
            desc = "install " .. package_name .. " and " .. desc
          end
          vim.api.nvim_create_autocmd("FileType", {
            callback = function()
              local function _setup()
                if original_setup(n, o) then
                  lspconfig[n].setup(o)
                end
              end

              local function install()
                local registry = require("mason-registry")
                if registry.is_installed(package_name) then
                  _setup()
                  return
                end

                local pkg = registry.get_package(package_name)
                if not pkg then
                  _setup()
                  return
                end

                vim.notify("Installing " .. pkg.name .. "...")
                pkg:install():once("closed", function()
                  if pkg:is_installed() then
                    vim.notify("Successfully installed " .. pkg.name .. ".")
                    vim.schedule(_setup)
                  else
                    vim.notify("Failed to install " .. pkg.name .. ".", vim.log.levels.WARN)
                  end
                end)
              end

              if package_name then
                install()
              else
                _setup()
              end
              return true
            end,
            pattern = o.filetypes or lspconfig[n].config_def.default_config.filetypes,
          })
          return su(n, o)
        end
      end

      opts.setup = wrapped_setup
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = {}
    end,
  },
  {
    "folke/noice.nvim",
    opts = {
      routes = {
        {
          filter = { event = "notify", kind = "warn", find = "^Mason package path not found for " },
          opts = { skip = true },
        },
      },
    },
  },
}
