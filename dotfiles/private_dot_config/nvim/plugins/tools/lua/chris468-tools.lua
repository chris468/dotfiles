---@class chris468.tools
---@field formatter chris468.tools.Formatter
---@field linter chris468.tools.Linter
---@field lsp chris468.tools.Lsp
local M = {}
local mt = {}

function mt.__index(tbl, key)
  tbl[key] = require("chris468-tools." .. key)
  return tbl[key]
end

return setmetatable(M, mt)
