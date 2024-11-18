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

--- @param t1 table<any, any[]>?
--- @param t2 table<any, any[]>?
--- @return table<any, any[]>
function M.merge_flatten(t1, t2)
  t1 = t1 or {}
  t2 = t2 or {}
  local keys = vim.fn.flatten({ vim.tbl_keys(t1), vim.tbl_keys(t2) }) --[[ @as any[] ]]

  local result = {}
  for _, k in ipairs(keys) do
    result[k] = vim.fn.flatten({ t1[k] or {}, t2[k] or {} })
  end

  return result
end

--- @generic T
--- @param value_or_fun T?|fun():T?
--- @param default T?
--- @return T?
function M.value_or_result(value_or_fun, default)
  if type(value_or_fun) == "function" then
    value_or_fun = value_or_fun()
  end
  return value_or_fun or default
end

M.mason = require("chris468.util.mason")

return M
