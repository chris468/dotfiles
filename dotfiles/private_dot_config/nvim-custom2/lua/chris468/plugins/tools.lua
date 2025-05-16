---@type chris468.config.ToolsByFiletype
---@return table<string, string[]>
local function convert(tools_by_filetype)
  local function filter(v)
    return type(v) == "string" or v.prerequisite == nil or v.prerequisite()
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
      { "<leader>m", "<cmd>Mason<CR>", desc = "Mason" },
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
    ft = vim.tbl_keys(formatters_by_ft),
    opts = {
      formatters_by_ft = formatters_by_ft,
    },
  },
  {
    "mfussenegger/nvim-lint",
    dependencies = { "mason.nvim" },
    ft = vim.tbl_keys(linters_by_ft),
    opts = {
      linters_by_ft = linters_by_ft,
    },
  },
}
