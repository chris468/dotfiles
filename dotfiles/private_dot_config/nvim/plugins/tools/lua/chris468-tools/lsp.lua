local Tool = require("chris468-tools.tool").Tool

local M = {}

---@class chris468.tools.Lsp.Options
---@field enabled? boolean
---@field public package? boolean
---@field lspconfig? vim.lsp.Config

---@class chris468.tools.Lsp : chris468.tools.Tool
---@field protected super chris468.tools.Tool
---@field lspconfig vim.lsp.Config
---@field new fun(self: chris468.tools.Lsp, name: string, opts?: chris468.tools.Lsp.Options, ...: table) : chris468.tools.Lsp
M.Lsp = Tool:extend() --[[ @as chris468.tools.Lsp ]]
M.Lsp.type = "LSP"
function M.Lsp:new(name, opts)
  opts = opts or {}
  return self:_new(name, {
    enabled = opts.enabled,
    package = opts.package,
  }, { lspconfig = opts.lspconfig or {} }) --[[ @as chris468.tools.Lsp ]]
end

function M.Lsp:name()
  if not self._tool_name then
    self._tool_name = vim.tbl_get(self:package() or {}, "spec", "neovim", "lspconfig")
  end

  return M.Lsp.super.name(self)
end

function M.Lsp:_tool_filetypes()
  return (self.lspconfig or {}).filetypes or (vim.lsp.config[self:name()] or {}).filetypes
end

return M
