local util = require("chris468-tools._util")
local installer = require("chris468-tools.installer")
local tool = require("chris468-tools.tool")
local M = {}

---@param bufnr integer
local function raise_filetype(bufnr)
  vim.defer_fn(function()
    vim.api.nvim_exec_autocmds("FileType", {
      buffer = bufnr,
    })
  end, 100)
end
---
---@param config? vim.lsp.Config
---@return vim.lsp.Config?
local function merge_completion_capabilities(config)
  if util.has_plugin("blink.cmp") then
    config = config or {}
    config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities, true)
  end

  return config
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

---@param linters string[]
local function run_installed_linters(linters)
  local installed_linters = vim.tbl_filter(function(v)
    return v:package() and v:package():is_installed()
  end, linters)

  if #installed_linters > 0 then
    require("lint").try_lint(vim.tbl_map(function(v)
      return v:name()
    end, installed_linters))
  end
end

---@param linters_by_ft table<string, Tool[]>
local function register_lint(linters_by_ft)
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
    group = vim.api.nvim_create_augroup("chris468.lint", { clear = true }),
    callback = function()
      local linters = linters_by_ft[vim.bo.filetype] or {}
      run_installed_linters(linters)
    end,
  })
end

---@class chris468.config._CachedLspConfig
---@field server_name string
---@field filetypes { [string]: true }
---@field public package? Package
---@field lspconfig vim.lsp.Config
---@field display_name string

---@param t Lsp
---@param bufnr integer
local function enable_and_install_lsp(t, bufnr)
  vim.lsp.config(t:name(), merge_completion_capabilities(t.lspconfig))
  vim.lsp.enable(t:name())
  util.install(t:package(), function()
    raise_filetype(bufnr)
  end, function()
    vim.lsp.disable(t:name())
  end, t:display_name())
end

---@generic TConfig
---@generic TTool : Tool
---@param opts  { [string]: { [string]: TConfig } }
---@param create_tool fun(name: string,config: TConfig) : TTool
---@return { [string]: TTool }
local function map_tools_by_filetype(opts, create_tool)
  local result = vim.defaulttable(function()
    return {}
  end)
  for _, configs in pairs(opts) do
    for name, config in pairs(configs) do
      local t = create_tool(name, config)
      if t.enabled then
        for _, ft in ipairs(t:filetypes()) do
          table.insert(result[ft], t)
        end
      end
    end
  end

  return result
end

---@param name string
---@param config chris468.config.LspServer
---@return Lsp
local function create_lsp_tool(name, config)
  local Lsp = require("chris468-tools.tool").Lsp
  return Lsp:new(name, { enabled = config.enabled, package = config.package, lspconfig = config.lspconfig })
end

--- @param opts chris468.config.LspConfig
--- @param group integer
local function lazily_install_lsps_by_filetype(opts, group)
  local _ = require("lspconfig")
  ---@type { [string]: Lsp[] }?
  local lsps_by_ft
  local handled_filetypes = util.make_set(Chris468.disable_filetypes)
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function(arg)
      local filetype = arg.match
      if handled_filetypes[filetype] then
        return
      end

      handled_filetypes[filetype] = true

      lsps_by_ft = lsps_by_ft or map_tools_by_filetype({ lsp = opts }, create_lsp_tool)

      for _, t in ipairs(lsps_by_ft[filetype] or {}) do
        enable_and_install_lsp(t, arg.buf)
      end
    end,
  })
end

--- @param opts chris468.config.LspConfig
function M.lspconfig(opts)
  local group = vim.api.nvim_create_augroup("chris468-tools.lsp", { clear = true })
  register_lsp_attach(group)
  register_dynamic_capability_handlers()
  lazily_install_lsps_by_filetype(opts, group)
end

---@param tools_by_ft { [string]: Tool[] }
---@param disabled_filetypes { [string]: true }
---@param tool_type string
local function lazily_install_tools_by_filetype(tools_by_ft, disabled_filetypes, tool_type)
  local handled_filetypes = disabled_filetypes

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("chris468." .. tool_type, { clear = true }),
    callback = function(arg)
      local filetype = arg.match
      if handled_filetypes[filetype] then
        return
      end
      handled_filetypes[filetype] = true

      for _, t in ipairs(tools_by_ft[filetype] or {}) do
        util.install(t:package(), function()
          raise_filetype(arg.buf)
        end, nil, t:display_name())
      end
    end,
  })
end

---@param opts { [string]: { [string]: chris468.config.Tool } }
function M.formatter_config(opts)
  local disabled_filetypes = util.make_set(Chris468.disable_filetypes)
  local tools_by_ft, names_by_ft = installer.map_tools_by_ft(opts, tool.Formatter)
  require("conform").setup(vim.tbl_extend("keep", { formatters_by_ft = names_by_ft }, opts))
  lazily_install_tools_by_filetype(tools_by_ft, disabled_filetypes, "formatter")
end

function M.linter_config(opts)
  local disabled_filetypes = util.make_set(Chris468.disable_filetypes)
  local tools_by_ft, names_by_ft = installer.map_tools_by_ft(opts.linters, tool.Linter)
  require("lint").linters_by_ft = names_by_ft
  lazily_install_tools_by_filetype(tools_by_ft, disabled_filetypes, "linter")
  register_lint(tools_by_ft)
end

return M
