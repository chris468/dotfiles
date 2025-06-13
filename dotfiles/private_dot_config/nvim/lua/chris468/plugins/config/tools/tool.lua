local Object = require("chris468.util.object")
local registry = require("mason-registry")

local M = {}

---@module "mason-registry"

---@class BaseTool.Options
---@field enabled? boolean
---@field public package? boolean
---@field filetypes? string[]
---@field tool_name? string

---@class BaseTool : chris468.Object
---@field protected super chris468.Object
---@field protected _package_name string
---@field protected _tool_name string
---@field private _package boolean|Package
---@field private _filetypes? string[]
---@field private _tool_type string
---@field private _display_name string?
---@field enabled? boolean
---@field new fun(self: BaseTool, tool_type: string, name: string, opts?: BaseTool.Options, ...: table) : BaseTool
---@field filetypes fun(self: BaseTool) : string[]
---@field protected _tool_filetypes fun(self: BaseTool) : string[]|nil
---@field public package fun(self: BaseTool) : Package|false
---@field display_name fun(self:BaseTool) : string
M.BaseTool = Object:extend("BaseTool") --[[ @as BaseTool]]

function M.BaseTool:new(tool_type, name, opts, ...)
  opts = opts or {}
  return Object.new(self, {
    _tool_type = tool_type,
    _package_name = name,
    _package = opts.package ~= false,
    enabled = opts.enabled ~= false,
    _filetypes = opts.filetypes,
    _tool_name = opts.tool_name,
  }, ...) --[[ @as BaseTool ]]
end

function M.BaseTool:filetypes()
  if not self._filetypes then
    self._filetypes = self:_tool_filetypes() or {}
  end

  return self._filetypes
end

function M.BaseTool:_tool_filetypes() end

function M.BaseTool:name()
  return self._tool_name or self._package_name
end

function M.BaseTool:display_name()
  self._display_name = self._display_name
    or string.format(
      "%s %s%s",
      self._tool_type,
      self._package_name,
      self._package_name == self:name() and "" or (" (%s)"):format(self:name())
    )

  return self._display_name
end

function M.BaseTool:package()
  if self._package == true then
    local ok, p = pcall(registry.get_package, self._package_name)
    self._package = ok and p or false
  end
  return self._package
end

---@class Tool : BaseTool
---@field protected super BaseTool
---@field new fun(self: Tool, tool_type: string, name: string, opts?: BaseTool.Options) : Tool
local Tool = M.BaseTool:extend("Tool") --[[ @as Tool ]]
function Tool:new(tool_type, name, opts)
  opts = opts or {}
  return Tool.super.new(self, tool_type, name, opts) --[[ @as Tool ]]
end

---@class LspTool.Options
---@field enabled? boolean
---@field public package? boolean
---@field lspconfig? vim.lsp.Config

---@class LspTool : BaseTool
---@field protected super BaseTool
---@field lspconfig vim.lsp.Config
---@field new fun(self: LspTool, name: string, opts?: LspTool.Options, ...: table) : LspTool
local LspTool = M.BaseTool:extend("LspTool") --[[ @as LspTool ]]
function LspTool:new(name, opts)
  opts = opts or {}
  return LspTool.super.new(self, "LSP", name, {
    enabled = opts.enabled,
    package = opts.package,
  }, { lspconfig = opts.lspconfig }) --[[ @as LspTool ]]
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
  LspTool = LspTool,
}
