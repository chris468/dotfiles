local Object = require("chris468.object")
local registry = require("mason-registry")

local M = {}

---@module "mason-registry"

---@class AbstractTool : chris468.Object
---@field protected super chris468.Object
---@field protected _name string|false
---@field private _package? string|Package|false
---@field private _configured_filetypes string[]
---@field private _filetypes? string[]
---@field enabled boolean
---@field new fun(self: AbstractTool, name: string, enabled?: boolean, package?: string|boolean, filetypes?: string[], ...: table) : AbstractTool
---@field filetypes fun(self: AbstractTool) : string[]
---@field protected _tool_filetypes fun(self: AbstractTool) : string[]|nil
---@field public package fun(self: AbstractTool) : Package|false
M.AbstractTool = Object:extend("AbstractTool")

function M.AbstractTool:new(name, enabled, package, filetypes, ...)
  return Object.new(self, {
    _name = name,
    enabled = enabled ~= false,
    _package = package or name,
    _filetypes = filetypes,
  }, ...)
end

function M.AbstractTool:filetypes()
  if not self._filetypes then
    self._filetypes = self:_tool_filetypes() or {}
  end

  return self._filetypes
end

function M.AbstractTool:_tool_filetypes() end

function M.AbstractTool:name()
  return self._name
end

function M.AbstractTool:package()
  if type(self._package) == "string" then
    local ok, p = pcall(registry.get_package, self._package)
    self._package = ok and p or false
  end
  return self._package --[[ @as Package|false ]]
end
