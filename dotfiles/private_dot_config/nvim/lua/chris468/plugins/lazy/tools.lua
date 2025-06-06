local cmd = require("chris468.util.keymap").cmd

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
    cmd = { "LspInfo", "LspInstall", "LspLog", "LspStart", "LspRestart", "LspUninstall" },
    config = function()
      require("chris468.plugins.config.tools").configure_lsp()
    end,
    dependencies = { "blink.cmp", optional = true },
    keys = {
      { "<leader>cL", cmd("LspInfo"), desc = "LSP info" },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason.nvim", "nvim-lspconfig" },
    opts = {
      automatic_enable = false,
      ensure_installed = {},
    },
  },
  {
    "stevearc/conform.nvim",
    dependencies = { "mason.nvim" },
    cmd = { "ConformInfo" },
    ft = vim.tbl_keys(formatters_by_ft),
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
      formatters_by_ft = formatters_by_ft,
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
