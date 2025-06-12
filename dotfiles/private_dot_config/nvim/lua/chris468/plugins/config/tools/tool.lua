local AbstractTool = require("chris468.plugins.config.tools.abstract_tool").AbstractTool

---@class Tool.Options : AbstractTool.Options
---@field tool_name? string

---@class Tool : AbstractTool
---@field protected super AbstractTool
---@field private _tool_name string?
---@field new fun(self: Tool, tool_type: string, name: string, opts?: Tool.Options) : Tool
local Tool = AbstractTool:extend("Tool") --[[ @as Tool ]]
function Tool:new(tool_type, name, opts)
  opts = opts or {}
  return Tool.super.new(self, tool_type, name, opts, { _tool_name = opts.tool_name }) --[[ @as Tool ]]
end

function Tool:name()
  return self._tool_name or self._package_name
end

---@class LspTool.Options
---@field enabled? boolean
---@field public package? boolean
---@field lspconfig? vim.lsp.Config

---@class LspTool : AbstractTool
---@field protected super AbstractTool
---@field lspconfig vim.lsp.Config
---@field new fun(self: LspTool, name: string, opts?: LspTool.Options, ...: table) : LspTool
local LspTool = AbstractTool:extend("LspTool") --[[ @as LspTool ]]
function LspTool:new(name, opts)
  opts = opts or {}
  return LspTool.super.new(self, "LSP", name, opts --[[ @as AbstractTool.Options ]], { _lspconfig = opts.lspconfig }) --[[ @as LspTool ]]
end

function LspTool:_tool_filetypes()
  return (self.lspconfig or {}).filetypes or (vim.lsp.config[self:name()] or {}).filetypes
end

return {
  Tool = Tool,
  LspTool = LspTool,
}
