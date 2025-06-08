local cmd = require("chris468.util.keymap").cmd

---@class chris468.config.LspServer
---@field enabled? boolean Whether to enable the server. Default true
---@field name? string The server config name. Defaults to package name, or lspconfig name from package if available.
---@field public package? boolean Whether there is a mason package. Defaults to true.
---@field lspconfig? vim.lsp.Config The server config. Defaults to empty

---@alias chris468.config.LspConfig table<string, chris468.config.LspServer> Map of package name to server config

---@class chris468.config.Formatter
---@field [1] string Formatter name
---@field enabled? boolean Whether to enable the formatter, default true
---@field public package? string Package name, if different than formatter, or false for no package

---@alias chris468.config.FormattersByFileType { string: (string|chris468.config.Formatter)[] }}

return {
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonLog", "MasonUninstall", "MasonUninstallAll", "MasonUpdate" },
    keys = {
      { "<leader>ci", cmd("checkhealth vim.lsp conform"), desc = "LSP/Formatter info" },
      { "<leader>M", cmd("Mason"), desc = "Mason" },
    },
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function(_, opts)
      require("chris468.plugins.config.tools").lspconfig(opts)
    end,
    dependencies = { "blink.cmp", optional = true },
    lazy = false,
    keys = {
      { "<leader>cL", cmd("LspInfo"), desc = "LSP info" },
    },
    -- This is custom config (nvim-lspconfig is just data and has no setup)
    ---@type chris468.config.LspConfig
    opts = {},
  },
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    config = function(_, opts)
      require("chris468.plugins.config.tools").formatter_config(opts)
    end,
    lazy = false,
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true })
        end,
        desc = "Format",
      },
      { "<leader>cF", cmd("ConformInfo"), desc = "Formatter info" },
    },
    opts = {
      default_format_opts = {
        lsp_format = "fallback",
      },
      -- formatters_by_ft is custom - a map of key to map of filetype to plugins.
      -- Outer map is to avoid conflicts, inner maps will be merged.
      ---@type {string: chris468.config.FormattersByFileType}
      formatters_by_ft = {},
      format_on_save = function(bufnr)
        if vim.g.format_on_save == false or vim.b[bufnr].format_on_save == false then
          return
        end

        return { timeout_ms = 500 }
      end,
    },
  },
  {
    "mfussenegger/nvim-lint",
    config = function(_, opts)
      require("chris468.plugins.config.tools").linter_config(opts)
    end,
    dependencies = { "mason.nvim" },
    lazy = false,
    opts = {
      -- linters_by_ft is custom - a map of key to map of filetype to plugins.
      -- Outer map is to avoid conflicts, inner maps will be merged.
      ---@type {string: chris468.config.FormattersByFileType}
      linters_by_ft = {},
    },
    version = false,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    main = "nvim-treesitter.configs",
    opts = {
      auto_install = true,
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    },
    version = false,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "VeryLazy",
    opts = {
      enable = true,
    },
    version = false,
  },
}
