---@class chris468.util.Terminal
local Terminal = require("plenary").class:extend()

---@class chris468.util.Terminal.ToggleOpts
---@field count number
---@field name? string

---@param opts chris468.util.Terminal.ToggleOpts
function Terminal:toggle(opts) ---@diagnostic disable-line: unused-local
  Terminal._abstract("toggle")
end

--- @param cmd string
--- @param display_name? string
function Terminal:background_command(cmd, display_name) ---@diagnostic disable-line: unused-local
  Terminal._abstract("background_command")
end

---@protected
function Terminal._abstract(method)
  error("abstract method: " .. method)
end

return Terminal
