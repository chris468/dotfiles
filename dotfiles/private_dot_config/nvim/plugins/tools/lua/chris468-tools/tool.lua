local Object = require("plenary").class

---@module "mason-registry"

---@class chris468.tools.Tool.Options
---@field enabled? boolean
---@field public package? boolean
---@field filetypes? string[]
---@field tool_name? string

---@class chris468.tools.Tool
---@field protected _package_name string
---@field protected _tool_name string
---@field private _package boolean|Package
---@field private _tool_type string
---@field private _display_name string?
---@field protected super Object
---@field protected _abstract fun(self: chris468.tools.Tool, method: string)
---@field extend fun(self: chris468.tools.Tool) : chris468.tools.Tool
---@field enabled? boolean
---@field new fun(name: string, opts?: chris468.tools.Tool.Options, ...: table) : chris468.tools.Tool
---@field protected _new fun(self: chris468.tools.Tool, name: string, opts?: chris468.tools.Tool.Options, ...: table) : chris468.tools.Tool
---@field filetypes fun(self: chris468.tools.Tool) : string[]
---@field protected _tool_filetypes fun(self: chris468.tools.Tool) : string[]|nil
---@field public package fun(self: chris468.tools.Tool) : Package|false
---@field display_name fun(self: chris468.tools.Tool) : string
---@field on_installed fun(self:chris468.tools.Tool, bufnr: integer)
---@field on_install_failed fun(self:chris468.tools.Tool, bufnr: integer)
---@field before_install fun(self:chris468.tools.Tool)
Tool = Object:extend() --[[ @as chris468.tools.Tool]]
Tool.type = "tool"

function Tool:__tostring()
  return self.type
end

---@param method string
function Tool:_abstract(method)
  error(("call to abstract method %s.%s"):format(self.type, method))
end

function Tool:new(_, _)
  ---@diagnostic disable-next-line: missing-return
  self:_abstract("new")
end

function Tool:_new(name, opts, ...)
  local o = {
    _package_name = name,
    _package = opts.package ~= false,
    enabled = opts.enabled ~= false,
    _filetypes = opts.filetypes,
    _tool_name = opts.tool_name,
  }
  if select("#", ...) > 0 then
    o = vim.tbl_extend("error", o, ...)
  end
  return setmetatable(o, self)
end

function Tool:filetypes()
  if not self._filetypes then
    self._filetypes = self:_tool_filetypes() or {}
  end

  return self._filetypes
end

function Tool:_tool_filetypes() end

function Tool:name()
  return self._tool_name or self._package_name
end

function Tool:display_name()
  self._display_name = self._display_name
    or string.format(
      "%s %s%s",
      self.type,
      self._package_name,
      self._package_name == self:name() and "" or (" (%s)"):format(self:name())
    )

  return self._display_name
end

function Tool:package()
  if self._package == true then
    local registry = require("mason-registry")
    local ok, p = pcall(registry.get_package, self._package_name)
    self._package = ok and p or false
  end
  return self._package
end

function Tool:on_installed(_) end

function Tool:on_install_failed(_) end

function Tool:before_install() end

return Tool
