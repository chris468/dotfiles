local have_mason_lspconfig, _ = pcall(require, "mason-lspconfig")
if not have_mason_lspconfig then
  return {
    to_packages = function()
      return {}
    end,
    to_filetypes = function()
      return {}
    end,
  }
end

local filetype_to_lspconfigs = require("mason-lspconfig.mappings.filetype")
local lspconfig_to_package = require("mason-lspconfig.mappings.server").lspconfig_to_package

local M = {}

---@return string[]
function M.to_packages(servers)
  ---@type table<string, true>
  local packages = {}
  for _, server in ipairs(servers) do
    local package = lspconfig_to_package[server]
    if package then
      packages[package] = true
    end
  end

  return vim.tbl_keys(packages)
end

---@return table<string, string[]>
function M.to_filetypes()
  local packages_to_filetypes = {}
  for ft, lsps in pairs(filetype_to_lspconfigs) do
    for _, lsp in ipairs(lsps) do
      local package = lspconfig_to_package[lsp]
      if package then
        packages_to_filetypes[package] = packages_to_filetypes[package] or {}
        table.insert(packages_to_filetypes[package], ft)
      end
    end
  end

  return packages_to_filetypes
end

return M
