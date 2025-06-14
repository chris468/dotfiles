local class = require("plenary").class

---@class chris468.Object
---@field new fun(self: chris468.Object, state: table, ...: table) : chris468.Object
---@field protected super chris468.Object
---@field protected _abstract fun(self: chris468.Object, method: string)
local Object = class:extend()
Object._type = "Object"

function Object:new(state, ...)
  local o = {}
  return setmetatable(vim.tbl_extend("error", o, state or {}, ...), self)
end

function Object:__tostring()
  return self._type
end

---@param name string
---@return Object
function Object:extend(name)
  local o = class.extend(self)
  o._type = name
  return o
end

---@param method string
function Object:_abstract(method)
  error(("call to abstract method %s.%s"):format(self._type, method))
end

return Object
