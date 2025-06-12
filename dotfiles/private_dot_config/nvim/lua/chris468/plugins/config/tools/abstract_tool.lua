local Object = require("chris468.util.object")
local registry = require("mason-registry")

local M = {}

---@module "mason-registry"

---@class AbstractTool.Options
---@field enabled? boolean
---@field public package? boolean
---@field filetypes? string[]

---@class AbstractTool : chris468.Object
---@field protected super chris468.Object
---@field protected _package_name string
---@field private _package boolean|Package
---@field private _filetypes? string[]
---@field private _tool_type string
---@field private _display_name string?
---@field enabled? boolean
---@field new fun(self: AbstractTool, tool_type: string, name: string, opts?: AbstractTool.Options, ...: table) : AbstractTool
---@field filetypes fun(self: AbstractTool) : string[]
---@field protected _tool_filetypes fun(self: AbstractTool) : string[]|nil
---@field public package fun(self: AbstractTool) : Package|false
---@field display_name fun(self:AbstractTool) : string
M.AbstractTool = Object:extend("AbstractTool") --[[ @as AbstractTool]]

function M.AbstractTool:new(tool_type, name, opts, ...)
  opts = opts or {}
  return Object.new(self, {
    _tool_type = tool_type,
    _package_name = name,
    _package = opts.package ~= false,
    enabled = opts.enabled ~= false,
    _filetypes = opts.filetypes,
  }, ...) --[[ @as AbstractTool ]]
end

function M.AbstractTool:filetypes()
  if not self._filetypes then
    self._filetypes = self:_tool_filetypes() or {}
  end

  return self._filetypes
end

function M.AbstractTool:_tool_filetypes() end

function M.AbstractTool:name()
  return self._package_name
end

function M.AbstractTool:display_name()
  self._display_name = self._display_name
    or string.format(
      "%s %s%s",
      self._tool_type,
      self._package_name,
      self._package_name == self:name() and "" or ("(%s)"):format(self:name())
    )

  return self._display_name
end

function M.AbstractTool:package()
  if self._package == true then
    local ok, p = pcall(registry.get_package, self._package_name)
    self._package = ok and p or false
  end
  return self._package
end

return M
