local util = require("chris468.util")

local M = {}

---@return table<string, string[]>
function M.to_filetypes()
  local have_conform, _ = pcall(require, "conform")
  if not have_conform then
    return {}
  end

  local lazyvim_util = require("lazyvim.util")

  local formatters_by_ft = lazyvim_util.opts("conform.nvim").formatters_by_ft
  formatters_by_ft["*"] = vim.list_extend(formatters_by_ft["*"] or {}, formatters_by_ft["_"] or {})
  formatters_by_ft["_"] = nil
  return util.invert_list_map(formatters_by_ft)
end

return M
