---@return table<string, string[]>
local M = {}
function M.to_filetypes()
  local have_dap, _ = pcall(require, "mason-nvim-dap")
  if not have_dap then
    return {}
  end

  return require("mason-nvim-dap.mappings.filetypes")
end

return M
