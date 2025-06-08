local cmd = require("chris468.util.keymap").cmd

---@class chris468.config.LspServer
---@field enabled? boolean Whether to enable the server. Default true
---@field name? string The server config name. Defaults to package name, or lspconfig name from package if available.
---@field package package? boolean Whether there is a mason package. Defaults to true.
---@field cfg? vim.lsp.Config The server config. Defaults to empty

---@alias chris468.config.LspConfig table<string, chris468.config.LspServer> Map of package name to server config

---@class chris468.config.Formatter
---@field [1] string Formatter name
---@field enabled? boolean Whether to enable the formatter, default true
---@field package package? string Package name, if different than formatter, or false for no package

---@alias chris468.config.FormattersByFileType { string: (string|chris468.config.Formatter)[] }}

---@type chris468.config.ToolsByFiletype
---@return table<string, string[]>
local function convert(tools_by_filetype)
  local function filter(v)
    if type(v) == "string" then
      return true
    elseif type(v.install) == "function" then
      return v.install()
    else
      return v.install ~= false
    end
  end

  local function extract_tool_name(v)
    return type(v) == "table" and v[1] or v
  end

  local function map(v)
    return vim.tbl_map(extract_tool_name, vim.tbl_filter(filter, v))
  end

  return vim.tbl_map(map, tools_by_filetype)
end

local formatters_by_ft = convert(Chris468.tools.formatters)
local linters_by_ft = convert(Chris468.tools.linters)

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
    cmd = { "LspInfo", "LspLog", "LspStart", "LspRestart" },
    event = { "BufReadPost", "BufNew" },
    config = function(_, opts)
      require("chris468.plugins.config.tools").lspconfig(opts)
    end,
    dependencies = { "blink.cmp", optional = true },
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
    cmd = { "ConformInfo" },
    config = function(_, opts)
      require("chris468.plugins.config.tools").formatter_config(opts)
    end,
    event = { "BufReadPost", "BufNew" },
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
      local lint = require("lint")
      lint.linters_by_ft = opts.linters_by_ft
      require("chris468.plugins.config.tools").register_lint(opts.linters_by_ft)
    end,
    dependencies = { "mason.nvim" },
    ft = vim.tbl_keys(linters_by_ft),
    opts = {
      linters_by_ft = linters_by_ft,
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
