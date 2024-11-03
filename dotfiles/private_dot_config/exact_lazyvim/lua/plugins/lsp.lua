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
          local lazyvim_utils = require("lazyvim.util")
          local server_mapping = require("mason-lspconfig.mappings.server").lspconfig_to_package
          local dap_mapping = require("mason-nvim-dap.mappings.filetypes")

          local opts = {
            conform = lazyvim_utils.opts("conform.nvim"),
            lint = lazyvim_utils.opts("nvim-lint"),
            lspconfig = lazyvim_utils.opts("nvim-lspconfig"),
            mason = lazyvim_utils.opts("mason.nvim"),
          }

          local ensure_installed = {}

          local function remove(package_names)
            for _, package_name in ipairs(package_names) do
              ensure_installed[package_name] = nil
            end
          end

          for _, package in ipairs(opts.mason.ensure_installed or {}) do
            ensure_installed[package] = true
          end
          vim.notify(vim.inspect({ all = vim.tbl_keys(ensure_installed) }))

          local linter_package_names = vim.tbl_flatten(vim.tbl_values(opts.lint.linters_by_ft))
          vim.notify(vim.inspect({ linters = linter_package_names, linters_by_ft = opts.lint.linters_by_ft }))
          remove(linter_package_names)
          vim.notify(vim.inspect({ without_linters = vim.tbl_keys(ensure_installed) }))

          local conform_package_names = vim.tbl_flatten(vim.tbl_values(opts.conform.formatters_by_ft))
          remove(conform_package_names)
          vim.notify(vim.inspect({ without_linters_formatters = vim.tbl_keys(ensure_installed) }))

          remove(vim.tbl_keys(dap_mapping))
          vim.notify(vim.inspect({ without_linters_formatters_dap = vim.tbl_keys(ensure_installed) }))

          local server_package_names = vim.tbl_map(function(p)
            return server_mapping[p] or p
          end, vim.tbl_keys(vim.tbl_extend("keep", opts.lspconfig.servers or {}, opts.lspconfig.setup or {})))
          remove(server_package_names)
          vim.notify(vim.inspect({ without_known = vim.tbl_keys(ensure_installed) }))

          local registry = require("mason-registry")

          local languages = { none = {}, missing = {} }
          for package_name, _ in pairs(ensure_installed) do
            local ok, package = pcall(registry.get_package, package_name)
            if ok then
              if #package.spec.languages == 0 then
                languages.none[package.name] = true
              else
                for _, language in ipairs(package.spec.languages) do
                  languages[language] = languages[language] or {}
                  languages[language][package.name] = true
                end
              end
            else
              languages.missing[package_name] = true
            end
          end

          -- for k, v in pairs(languages) do
          --   languages[k] = vim.tbl_keys(v)
          -- end

          vim.notify(vim.inspect(languages))
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
