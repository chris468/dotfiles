local Object = require("plenary").class

---@class chris468.util.Terminal.Opts
---@field count? integer
---@field name? string

---@class chris468.util.Terminal
---@field toggle fun(opts: chris468.util.Terminal.Opts): chris468.util.Terminal
---@field protected _abstract fun(method: string)

local Terminal = Object:extend() --@as chris468.util.Terminal

function Terminal.toggle(opts)
  Terminal._abstract("toggle")
end

function Terminal._abstract(method)
  error("Method " .. method .. " is abstract")
end

return Terminal
