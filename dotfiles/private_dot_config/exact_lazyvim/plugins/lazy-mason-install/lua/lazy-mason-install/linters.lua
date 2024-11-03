local util = require("chris468.util")
local M = {}

---@return table<string, string[]>
function M.to_filetypes()
  local have_lint, _ = pcall(require, "lint")
  if not have_lint then
    return {}
  end

  local lazyvim_util = require("lazyvim.util")

  local linters_to_filetypes = util.invert_list_map(lazyvim_util.opts("nvim-lint").linters_by_ft)
  return linters_to_filetypes
end

return M
