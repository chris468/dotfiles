local M = {}

---@param s string
---@return string
function M.capitalize(s)
  local result, _ = s:gsub("^%l", string.upper)
  return result
end

---@param s string
---@param delimiters string
---@return string[]
function M.split(s, delimiters)
  local t = {}
  for str in s:gmatch("([^" .. delimiters .. "]+)") do
    t[#t + 1] = str
  end

  return t
end

return M
