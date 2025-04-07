return {
  {
    config = function(_, opts)
      require("chris468.lazy-mason-install").setup(opts)
    end,
    dir = vim.fn.stdpath("config") .. "/lua/chris468/lazy-mason-install",
    lazy = true,
    opts_extend = { "packages_for_filetypes" },
    opts = Chris468.options.lsp.install,
  },
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
    dependencies = { "lazy-mason-install" },
    opts = function(_, opts)
      local filter = require("chris468.lazy-mason-install").filter
      local config = Chris468.options.lsp
      opts.ensure_installed = filter(opts.ensure_installed or {}, config.ensure_not_installed)

      opts.ensure_installed = vim.list_extend(opts.ensure_installed or {}, config.ensure_installed)
    end,
  },
  {
    "conform.nvim",
    opts = function(_, opts)
      local filter = require("chris468.lazy-mason-install").filter
      for ft, config in pairs(Chris468.options.lsp.formatters) do
        local formatters = {}
        for _, v in ipairs(config) do
          formatters[#formatters + 1] = v
        end

        if config._replace then
          opts.formatters_by_ft[ft] = formatters
        else
          opts.formatters_by_ft[ft] = vim.list_extend(opts.formatters_by_ft[ft] or {}, formatters)
        end
      end

      for ft, formatters in pairs(opts.formatters_by_ft) do
        local config = Chris468.options.lsp.formatters[ft]
        local remove = config and config._remove or {}
        opts.formatters_by_ft[ft] = filter(formatters, remove, Chris468.options.lsp.ensure_not_installed)
      end
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
        original(vim.tbl_extend("force", o, { ensure_installed = {} }))
      end

      return opts
    end,
  },
  { "mason-nvim-dap.nvim", optional = true },
  {
    "folke/noice.nvim",
    opts = {
      routes = {
        --- Some LazyVim extra configurations use a helper that asserts that a mason package path is present
        --- Squash that error b/c that package may not need to be installed. The message can still be seen
        --- in the history.
        {
          filter = { event = "notify", kind = "warn", find = "^Mason package path not found for " },
          opts = { skip = true },
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- only install parsers needed by noice upfront
      opts.ensure_installed = {
        "bash",
        "lua",
        "markdown",
        "markdown_inline",
        "regex",
        "vim",
      }

      opts.auto_install = true
      return opts
    end,
  },
  {
    "nvim-lspconfig",
    opts = Chris468.options.lsp.lspconfig,
  },
}
