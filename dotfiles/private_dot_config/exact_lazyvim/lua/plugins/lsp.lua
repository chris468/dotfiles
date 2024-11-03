local util = require("chris468.util")
return {
  {
    dir = vim.fn.stdpath("config") .. "/plugins/lazy-mason-install",
    dependencies = {
      {
        "mason.nvim",
        config = function(_, opts)
          -- LazyVim's `config` for mason installs all packages in `opts.ensure_installed`
          -- and registers w/ mason registry to emit `FileType` on any successful package
          -- install.
          --
          -- Instead, we will install (if necessary) when required by the current filetype,
          -- and only emit `FileType` once all have finished installing.
          require("mason").setup({ opts })
        end,
      },
      {
        "mason-lspconfig.nvim",
        optional = true,
        opts = function(_, opts)
          local mlspc = require("mason-lspconfig")

          -- LazyVim's `config` for lspconfig installs all registered servers by passing
          -- them as `ensure_installed` to mason-lspconfig setup.
          --
          -- Instead, we want to install (if necessary) when required by the current filetype.
          -- LazyVim's lspconfig config does a bunch of other stuff that we still want to do,
          -- so replace mason-lspconfig's `setup` to ignore `ensure_installed`.
          local original = mlspc.setup

          mlspc.setup = function(o) ---@diagnostic disable-line: duplicate-set-field
            vim.notify("mason-lspconfig setup")
            original(vim.tbl_extend("force", o, { ensure_installed = {} }))
          end

          return opts
        end,
      },
      { "mason-nvim-dap.nvim", optional = true },
      { "nvim-lspconfig", optional = true },
    },
    opts = function()
      local lazyvim_util = require("lazyvim.util")

      ---@return string[]
      local function lsps_to_install()
        local lspconfig_opts = lazyvim_util.opts("nvim-lspconfig")
        local lspconfigs = vim.tbl_extend("force", lspconfig_opts.setup or {}, lspconfig_opts.servers or {})

        for lsp, config in pairs(lspconfigs) do
          if config.enabled == false or config.mason == false then
            lspconfigs[lsp] = nil
          end
        end

        return vim.tbl_keys(lspconfigs)
      end

      return {
        lsp_servers = lsps_to_install(),
        packages = lazyvim_util.opts("mason.nvim").ensure_installed or {},
      }
    end,
  },
}
