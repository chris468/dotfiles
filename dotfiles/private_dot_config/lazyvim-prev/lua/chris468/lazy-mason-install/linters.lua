local util = require("chris468.util")
local lazyvim = {
  util = require("lazyvim.util"),
}
local M = {}

---@return table<string, string[]>
function M.to_filetypes()
  if not lazyvim.util.has("nvim-lint") then
    return {}
  end

  local linters_to_filetypes = util.invert_list_map(lazyvim.util.opts("nvim-lint").linters_by_ft)
  return linters_to_filetypes
end

return M
