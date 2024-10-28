return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- opts._servers = opts.servers
      -- opts.servers = {}
      --
      -- opts._setup = opts.setup
      -- opts.setup = {}

      -- for each server, server_opts in servers
      --   server_opts.mason = false -- to prevent LazyVim plugin config from calling mason install.
      --                        -- Will immediately set up instead.
      --   original_setup = setup[server] or function() return false end
      --   setup[server] = function(s, o)
      --     on filetype o.filetypes or lspconfig[s].default_config.filetypes {
      --        install the server
      --        if not original_setup(s, o) then
      --          lspconfig[s].setup(o)
      --        end
      --     }
      --     return true
      --   end
      -- end

      local function wrap(setup, opts)
        if opts.wrapped then
          return true
        end

        opts.wrapped = true

        return function(name, opts)
          local lspconfig = require("lspconfig")

          setup = setup or function()
            return false
          end
          local desc = "Install and configure " .. name .. "lsp server"
          vim.api.nvim_create_autocmd("FileType", {
            callback = function()
              -- TODO: install
              vim.notify("TODO: Install " .. name)
              if setup(name, opts) ~= true then
                vim.notify("seting up " .. name)
                lspconfig[name].setup(opts)
              end
              return true
            end,
            desc = desc,
            group = vim.api.nvim_create_augroup(desc, { clear = true }),
            pattern = opts.filetypes or lspconfig[name].config_def.default_config.filetypes,
          })

          return true
        end
      end

      for server, server_opts in pairs(opts.servers) do
        server_opts.mason = false
        opts.setup[server] = wrap(opts.setup[server], server_opts)
      end
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
