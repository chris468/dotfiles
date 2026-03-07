local M = {}

---@param lhs string
---@param mode string|string[]
---@return boolean
local function is_mapped(lhs, mode)
  local modes = type(mode) == "table" and mode or { mode }
  for _, current_mode in ipairs(modes) do
    if vim.fn.maparg(lhs, current_mode) ~= "" then
      return true
    end
  end
  return false
end

---@param mode string|string[]
---@param lhs_candidates string[]
---@param rhs string|function
---@param opts table
---@return string|nil
function M.set_first_available(mode, lhs_candidates, rhs, opts)
  for _, lhs in ipairs(lhs_candidates) do
    if not is_mapped(lhs, mode) then
      vim.keymap.set(mode, lhs, rhs, opts)
      return lhs
    end
  end
  return nil
end

return M
