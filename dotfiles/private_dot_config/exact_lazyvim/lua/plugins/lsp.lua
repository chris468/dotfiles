return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "nvim-lint",
      "conform.nvim",
    },
    lazy = false,
    opts = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          local track = require("lazy.util").track
          track("map packages to filetypes")
          local util = require("chris468.util")

          local lazyvim_utils = require("lazyvim.util")
          local server_to_package = require("mason-lspconfig.mappings.server").lspconfig_to_package
          local filetype_to_dap = util.invert_list_map(require("mason-nvim-dap.mappings.filetypes"))
          local filetype_to_lsp = require("mason-lspconfig.mappings.filetype")
          local filetype_to_linter = lazyvim_utils.opts("nvim-lint").linters_by_ft or {}
          local filetype_to_formatter = lazyvim_utils.opts("conform.nvim").formatters_by_ft or {}

          track("lsp->package")
          local filetype_to_lsppackage = {}
          for ft, lsps in pairs(filetype_to_lsp) do
            filetype_to_lsppackage[ft] = {}
            for _, lsp in ipairs(lsps) do
              table.insert(filetype_to_lsppackage[ft], server_to_package[lsp])
            end
          end
          track()

          track("merge")
          local filetype_to_package =
            util.merge_list_maps(filetype_to_dap, filetype_to_lsppackage, filetype_to_linter, filetype_to_formatter)
          track()

          track("invert")
          local package_to_filetype = util.invert_list_map(filetype_to_package)
          track()

          local lspconfig_opts = lazyvim_utils.opts("nvim-lspconfig")
          local ensure_installed = {}

          track("registered servers -> ensure_installed")
          for _, s in
            ipairs(vim.tbl_keys(vim.tbl_extend("keep", lspconfig_opts.servers or {}, lspconfig_opts.setup or {})))
          do
            local p = server_to_package[s]
            if s then
              table.insert(ensure_installed, p)
            end
          end
          track()

          track("append packages")
          vim.list_extend(ensure_installed, lazyvim_utils.opts("mason.nvim").ensure_installed or {})
          track()

          track("identify")
          local ptf = {}
          for _, p in ipairs(ensure_installed) do
            ptf[p] = package_to_filetype[p] or "<unknown>"
          end
          track()

          track()

          vim.notify(vim.inspect({ filetype_to_dap = filetype_to_dap }))
          vim.notify(vim.inspect({ enusre_installed = ensure_installed }))

          vim.notify(vim.inspect({ filetype_to_package = filetype_to_package }))
          vim.notify(vim.inspect({ package_to_filetype = package_to_filetype }))
          vim.notify(vim.inspect({ ptf = ptf }))
        end,
      })
    end,
  },
  {
    "williamboman/mason.nvim",
    config = function(_, opts)
      -- LazyVim's `config` for mason installs all packages in `opts.ensure_installed`
      -- and registers w/ mason registry to emit `FileType` on any successful package
      -- install.
      --
      -- Instead, we will install (if necessary) when required by the current filetype,
      -- and only emit `FileType` once all have finished installing.
      vim.notify("mason setup")
      require("mason").setup({ opts })
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      local mlspc = require("mason-lspconfig")

      -- LazyVim's `config` for lspconfig installs all registered servers by passing
      -- them as `ensure_installed` to mason-lspconfig setup.
      --
      -- Instead, we want to install (if necessary) when required by the current filetype.
      -- LazyVim's lspconfig config does a bunch of other stuff that we still want to do,
      -- so replace mason-lspconfig's `setup` to ignore `ensure_installed`.
      local original = mlspc.setup
      mlspc.setup = function(o)
        vim.notify("mason-lspconfig setup")
        original(vim.tbl_extend("force", o, { ensure_installed = {} }))
      end

      return opts
    end,
  },
}
