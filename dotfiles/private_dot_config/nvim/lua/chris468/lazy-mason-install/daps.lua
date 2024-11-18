local lazyvim = {
  util = require("lazyvim.util"),
}

local M = {}

---@return table<string, string[]>
function M.to_filetypes()
  if not lazyvim.util.has("mason-nvim-dap.nvim") then
    return {}
  end

  local adapter_to_filetypes = require("mason-nvim-dap.mappings.filetypes")
  local adapter_to_packages = require("mason-nvim-dap.mappings.source").nvim_dap_to_package

  local package_to_filetypes = {}
  for adapter, filetypes in pairs(adapter_to_filetypes) do
    package_to_filetypes[adapter_to_packages[adapter] or adapter] = filetypes
  end

  return package_to_filetypes
end

return M
