local Object = require("chris468.util.object")
local registry = require("mason-registry")

---@module "mason-registry"

---@class Tool.Options
---@field enabled? boolean
---@field public package? boolean
---@field filetypes? string[]
---@field tool_name? string

---@class Tool : chris468.Object
---@field protected super chris468.Object
---@field protected _package_name string
---@field protected _tool_name string
---@field private _package boolean|Package
---@field private _filetypes? string[]
---@field private _tool_type string
---@field private _display_name string?
---@field enabled? boolean
---@field new fun(name: string, opts?: Tool.Options) : Tool
---@field protected _new fun(self: Tool, tool_type: string, name: string, opts?: Tool.Options, ...: table) : Tool
---@field filetypes fun(self: Tool) : string[]
---@field protected _tool_filetypes fun(self: Tool) : string[]|nil
---@field public package fun(self: Tool) : Package|false
---@field display_name fun(self:Tool) : string
Tool = Object:extend("Tool") --[[ @as Tool]]

function Tool:new(name, opts)
  self:_abstract("new")
end

function Tool:_new(tool_type, name, opts, ...)
  opts = opts or {}
  return Object.new(self, {
    _tool_type = tool_type,
    _package_name = name,
    _package = opts.package ~= false,
    enabled = opts.enabled ~= false,
    _filetypes = opts.filetypes,
    _tool_name = opts.tool_name,
  }, ...) --[[ @as Tool ]]
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
      self._tool_type,
      self._package_name,
      self._package_name == self:name() and "" or (" (%s)"):format(self:name())
    )

  return self._display_name
end

function Tool:package()
  if self._package == true then
    local ok, p = pcall(registry.get_package, self._package_name)
    self._package = ok and p or false
  end
  return self._package
end

---@class Formatter : Tool
---@field protected super Tool
---@field new fun(self: Formatter, name: string, opts?: Tool.Options) : Formatter
local Formatter = Tool:extend("Formatter") --[[ @as Formatter ]]
function Formatter:new(name, opts)
  opts = opts or {}
  return self:_new("formatter", name, opts) --[[ @as Formatter ]]
end

---@class Linter : Tool
---@field protected super Tool
---@field new fun(self: Linter, name: string, opts?: Tool.Options) : Linter
local Linter = Tool:extend("Linter") --[[ @as Linter ]]
function Linter:new(name, opts)
  opts = opts or {}
  return self:_new("linter", name, opts) --[[ @as Linter ]]
end

---@class Lsp.Options
---@field enabled? boolean
---@field public package? boolean
---@field lspconfig? vim.lsp.Config

---@class Lsp : Tool
---@field protected super Tool
---@field lspconfig vim.lsp.Config
---@field new fun(self: Lsp, name: string, opts?: Lsp.Options, ...: table) : Lsp
local Lsp = Tool:extend("Lsp") --[[ @as Lsp ]]
function Lsp:new(name, opts)
  opts = opts or {}
  return self:_new("LSP", name, {
    enabled = opts.enabled,
    package = opts.package,
  }, { lspconfig = opts.lspconfig or {} }) --[[ @as Lsp ]]
end

function Lsp:name()
  if not self._tool_name then
    self._tool_name = vim.tbl_get(self:package() or {}, "spec", "neovim", "lspconfig")
  end

  return Lsp.super.name(self)
end

function Lsp:_tool_filetypes()
  return (self.lspconfig or {}).filetypes or (vim.lsp.config[self:name()] or {}).filetypes
end

return {
  Tool = Tool,
  Formatter = Formatter,
  Linter = Linter,
  Lsp = Lsp,
}
