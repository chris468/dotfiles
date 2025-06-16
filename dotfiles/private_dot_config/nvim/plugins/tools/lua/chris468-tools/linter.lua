local Tool = require("chris468-tools.tool").Tool

local M = {}

---@class chris468.tools.Linter : chris468.tools.Tool
---@field protected super chris468.tools.Tool
---@field new fun(self: chris468.tools.Linter, name: string, opts?: chris468.tools.Tool.Options) : chris468.tools.Linter
M.Linter = Tool:extend() --[[ @as chris468.tools.Linter ]]
M.Linter.type = "linter"
function M.Linter:new(name, opts)
  opts = opts or {}
  return self:_new(name, opts) --[[ @as chris468.tools.Linter ]]
end

return M
