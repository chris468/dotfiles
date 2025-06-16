local Tool = require("chris468-tools.tool").Tool

local M = {}

---@class chris468.tools.Formatter : chris468.tools.Tool
---@field protected super chris468.tools.Tool
---@field new fun(self: chris468.tools.Formatter, name: string, opts?: chris468.tools.Tool.Options) : chris468.tools.Formatter
M.Formatter = Tool:extend() --[[ @as chris468.tools.Formatter ]]
M.Formatter.type = "formatter"
function M.Formatter:new(name, opts)
  opts = opts or {}
  return self:_new(name, opts) --[[ @as chris468.tools.Formatter ]]
end

return M
