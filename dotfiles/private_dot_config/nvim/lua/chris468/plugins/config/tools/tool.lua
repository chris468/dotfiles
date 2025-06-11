local AbstractTool = require("chris468.plugins.config.tools.abstract_tool")

---@class Tool : AbstractTool
---@field protected super AbstractTool
---@field new fun(self: Tool, name: string, enabled?: boolean, package?: string|boolean, filetypes?: string[], ...: table) : Tool
local Tool = AbstractTool:extend("Tool")

---@class LspTool : AbstractTool
---@field protected super AbstractTool
---@field private _lspconfig vim.lsp.Config
---@field new fun(self: LspTool, name: string, enabled?: boolean, package?: string|boolean, filetypes?: string[], lspconfig?: vim.lsp.Config) : LspTool
local LspTool = AbstractTool:extend("LspTool")
function LspTool:new(name, enabled, package, filetypes, lspconfig)
  return LspTool.super.new(self, name, enabled, package, filetypes, { _lspconfig = lspconfig }) --[[ @as LspTool ]]
end

function LspTool:_tool_filetypes()
  return (self._lspconfig or {}).filetypes or vim.config[self._name].filetypes
end
