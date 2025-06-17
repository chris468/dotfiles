local Tool = require("chris468-tools.tool").Tool
local util = require("chris468-tools._util")
local installer = require("chris468-tools.installer")

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

---@param config? vim.lsp.Config
---@return vim.lsp.Config?
local function merge_completion_capabilities(config)
  if util.has_plugin("blink.cmp") then
    config = config or {}
    config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities, true)
  end

  return config
end

function M.Lsp:before_install()
  vim.lsp.config(self:name(), merge_completion_capabilities(self.lspconfig))
  vim.lsp.enable(self:name())
end

function M.Lsp:on_installed(bufnr)
  util.raise_filetype(bufnr)
end

function M.Lsp:on_install_failed(_)
  vim.lsp.disable(self:name())
end

---@param bufnr integer
---@param client vim.lsp.Client
local function configure_inlay_hints(bufnr, client)
  if
    vim.api.nvim_buf_is_valid(bufnr)
    and vim.bo[bufnr].buftype == ""
    and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, bufnr)
  then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
end

---@param bufnr integer
---@param client vim.lsp.Client
local function lsp_attach(bufnr, client)
  configure_inlay_hints(bufnr, client)
end

--@param group integer
local function register_lsp_attach(group)
  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(arg)
      local bufnr = arg.buf
      local client = vim.lsp.get_client_by_id(arg.data.client_id)
      if client then
        lsp_attach(bufnr, client)
      end
    end,
  })
end

local function register_dynamic_capability_handlers()
  local original = vim.lsp.handlers[vim.lsp.protocol.Methods.client_registerCapability]
  vim.lsp.handlers[vim.lsp.protocol.Methods.client_registerCapability] = function(err, result, context, config)
    local ret = original(err, result, context, config)
    local client = vim.lsp.get_client_by_id(context.client_id) or {}
    for bufnr, _ in pairs(client.attached_buffers or {}) do
      configure_inlay_hints(bufnr, client)
    end
    return ret
  end
end

--- @param opts chris468.config.LspConfig
function M.setup(opts)
  local group = vim.api.nvim_create_augroup("chris468-tools.lsp", { clear = true })
  register_lsp_attach(group)
  register_dynamic_capability_handlers()
  local tools = installer.map_tools_by_filetype(opts, M.Lsp, opts.disabled_filetypes)(opts, group)
  installer.install_on_filetype(tools.tools_by_ft, group)
end

return M
