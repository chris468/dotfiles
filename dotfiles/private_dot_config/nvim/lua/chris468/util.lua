local M = {}

--- @param list string|string[]
--- @param val string
--- @return boolean
function M.contains(list, val)
  if type(list) == "table" then
    return vim.tbl_contains(list, val)
  else
    return list == val
  end
end

return M
