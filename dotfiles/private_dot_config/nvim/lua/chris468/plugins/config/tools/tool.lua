local AbstractTool = require("chris468.plugins.config.tools.abstract_tool").AbstractTool

---@class Tool : AbstractTool
---@field protected super AbstractTool
---@field private _tool_name string?
---@field new fun(self: Tool, tool_type: string, name: string, enabled?: boolean, package?: boolean, filetypes?: string[], tool_name?: string) : Tool
local Tool = AbstractTool:extend("Tool") --[[ @as Tool ]]
function Tool:new(tool_type, name, enabled, package, filetypes, tool_name)
  return Tool.super.new(self, tool_type, name, enabled, package, filetypes, { _tool_name = tool_name }) --[[ @as Tool ]]
end

function Tool:name()
  return self._tool_name or self._package_name
end

---@class LspTool : AbstractTool
---@field protected super AbstractTool
---@field lspconfig vim.lsp.Config
---@field new fun(self: LspTool, name: string, enabled?: boolean, package?: boolean, lspconfig?: vim.lsp.Config, ...: table) : LspTool
local LspTool = AbstractTool:extend("LspTool") --[[ @as LspTool ]]
function LspTool:new(name, enabled, package, lspconfig)
  return LspTool.super.new(self, "LSP", name, enabled, package, nil, { _lspconfig = lspconfig }) --[[ @as LspTool ]]
end

function LspTool:_tool_filetypes()
  return (self.lspconfig or {}).filetypes or (vim.lsp.config[self:name()] or {}).filetypes
end

return {
  Tool = Tool,
  LspTool = LspTool,
}
