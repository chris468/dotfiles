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
    opts = function(_, opts)
      local lazyvim_utils = require("lazyvim.util")
      local lspconfig_to_package = require("mason-lspconfig.mappings.server").lspconfig_to_package

      ---@return string[]
      local function lsps_to_install()
        local lspconfig_opts = lazyvim_utils.opts("nvim-lspconfig")
        local lspconfigs = {}
        for server, _ in pairs(lspconfig_opts.setup) do
          local package = lspconfig_to_package[server]
          if package then
            lspconfigs[package] = true
          end
        end
        for server, config in pairs(lspconfig_opts.servers or {}) do
          local package = lspconfig_to_package[server]
          if package then
            if config.enabled == false or config.mason == false then
              lspconfigs[package] = nil
            else
              lspconfigs[package] = true
            end
          end
        end
        return vim.tbl_keys(lspconfigs)
      end

      ---@return table<string, string[]>
      local function map_lsp_to_filetypes()
        local have_lspconfig, _ = pcall(require, "lspconfig")
        local have_mason_lspconfig, _ = pcall(require, "mason-lspconfig")
        if not have_lspconfig or not have_mason_lspconfig then
          return {}
        end

        local filetype_to_lspconfigs = require("mason-lspconfig.mappings.filetype")

        local package_to_filetypes = {}
        for ft, lsps in pairs(filetype_to_lspconfigs) do
          for _, lsp in ipairs(lsps) do
            local package = lspconfig_to_package[lsp]
            if package then
              package_to_filetypes[package] = package_to_filetypes[package] or {}
              table.insert(package_to_filetypes[package], ft)
            end
          end
        end

        return package_to_filetypes
      end

      ---@return table<string, string[]>
      local function map_linter_to_filetypes()
        local have_lint, _ = pcall(require, "lint")
        if not have_lint then
          return {}
        end
        local linter_to_filetypes = util.invert_list_map(lazyvim_utils.opts("nvim-lint").linters_by_ft)
        return linter_to_filetypes
      end

      ---@return table<string, string[]>
      local function map_formatter_to_filetypes()
        local have_conform, _ = pcall(require, "conform")
        if not have_conform then
          return {}
        end
        return util.invert_list_map(lazyvim_utils.opts("conform.nvim").formatters_by_ft)
      end

      ---@return table<string, string[]>
      local function map_dap_to_filetypes()
        local have_dap, _ = pcall(require, "mason-nvim-dap")
        if not have_dap then
          return {}
        end

        return require("mason-nvim-dap.mappings.filetypes")
      end

      local package_to_filetypes = util.merge_list_maps(
        map_lsp_to_filetypes(),
        map_linter_to_filetypes(),
        map_formatter_to_filetypes(),
        map_dap_to_filetypes()
      )

      ---@type table<string, true>
      local packages_with_unknown_filetypes = {}
      local install_for_filetypes = {}
      local original_ensure_installed = lazyvim_utils.opts("mason.nvim").ensure_installed or {}
      local ensure_installed = vim.list_extend(lsps_to_install(), original_ensure_installed)
      for _, package in ipairs(ensure_installed) do
        if not install_for_filetypes[package] then
          local filetypes = package_to_filetypes[package]
          if filetypes then
            install_for_filetypes[package] = filetypes
          else
            packages_with_unknown_filetypes[package] = true
            install_for_filetypes[package] = { "*" }
          end
        end
      end

      if not vim.tbl_isempty(packages_with_unknown_filetypes) then
        vim.notify(
          "Could not associate packages with filetype, always installing: \n  "
            .. table.concat(vim.tbl_keys(packages_with_unknown_filetypes), "\n  "),
          vim.log.levels.WARN
        )
      end

      local packages_by_filetype = util.invert_list_map(install_for_filetypes)

      opts.packages_by_ft = packages_by_filetype
    end,
  },
}
