local AbstractTool = require("chris468.plugins.config.tools.abstract_tool").AbstractTool

---@class Tool : AbstractTool
---@field protected super AbstractTool
---@field new fun(self: Tool, tool_type: string, name: string, opts?: AbstractTool.Options) : Tool
local Tool = AbstractTool:extend("Tool") --[[ @as Tool ]]
function Tool:new(tool_type, name, opts)
  opts = opts or {}
  return Tool.super.new(self, tool_type, name, opts) --[[ @as Tool ]]
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
  return LspTool.super.new(self, "LSP", name, opts --[[ @as AbstractTool.Options ]], { lspconfig = opts.lspconfig }) --[[ @as LspTool ]]
end

function LspTool:_tool_filetypes()
  return (self.lspconfig or {}).filetypes or (vim.lsp.config[self:name()] or {}).filetypes
end

return {
  Tool = Tool,
  LspTool = LspTool,
}
