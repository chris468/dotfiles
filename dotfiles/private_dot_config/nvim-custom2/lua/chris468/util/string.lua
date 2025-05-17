local M = {}

---@param s string
---@return string
function M.capitalize(s)
  local result, _ = s:gsub("^%l", string.upper)
  return result
end

return M
