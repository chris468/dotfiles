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

---@class FormatterTool : Tool
---@field protected super Tool
---@field new fun(self: FormatterTool, name: string, opts?: Tool.Options) : FormatterTool
local FormatterTool = Tool:extend("FormatterTool") --[[ @as FormatterTool ]]
function FormatterTool:new(name, opts)
  opts = opts or {}
  return self:_new("formatter", name, opts) --[[ @as FormatterTool ]]
end

---@class LinterTool : Tool
---@field protected super Tool
---@field new fun(self: LinterTool, name: string, opts?: Tool.Options) : LinterTool
local LinterTool = Tool:extend("LinterTool") --[[ @as LinterTool ]]
function LinterTool:new(name, opts)
  opts = opts or {}
  return self:_new("linter", name, opts) --[[ @as LinterTool ]]
end

---@class LspTool.Options
---@field enabled? boolean
---@field public package? boolean
---@field lspconfig? vim.lsp.Config

---@class LspTool : Tool
---@field protected super Tool
---@field lspconfig vim.lsp.Config
---@field new fun(self: LspTool, name: string, opts?: LspTool.Options, ...: table) : LspTool
local LspTool = Tool:extend("LspTool") --[[ @as LspTool ]]
function LspTool:new(name, opts)
  opts = opts or {}
  return self:_new("LSP", name, {
    enabled = opts.enabled,
    package = opts.package,
  }, { lspconfig = opts.lspconfig or {} }) --[[ @as LspTool ]]
end

function LspTool:name()
  if not self._tool_name then
    self._tool_name = vim.tbl_get(self:package() or {}, "spec", "neovim", "lspconfig")
  end

  return LspTool.super.name(self)
end

function LspTool:_tool_filetypes()
  return (self.lspconfig or {}).filetypes or (vim.lsp.config[self:name()] or {}).filetypes
end

return {
  Tool = Tool,
  FormatterTool = FormatterTool,
  LinterTool = LinterTool,
  LspTool = LspTool,
}
