local notify = require("chris468.util").schedule_notify
local M = {}

local _lsp_package

---@param lsp string
---@return string
local function lsp_package(lsp)
  if not _lsp_package then
    _lsp_package = require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package
  end

  return _lsp_package[lsp]
end

---@type { [string]: boolean }
local installed_tools_for_filetype = {}

---@param bufnr integer
local function raise_filetype(bufnr)
  vim.defer_fn(function()
    vim.api.nvim_exec_autocmds("FileType", {
      buffer = bufnr,
    })
  end, 100)
end

---@param package_name string
---@param install? chris468.config.ShouldInstallTool
---@return boolean
local function should_install_tool(package_name, install)
  local should_install, description
  if install == nil then
    should_install = true
  elseif type(install) == "function" then
    should_install, description = install()
  else
    should_install = install
  end

  if not should_install and description then
    notify("Skipping " .. package_name .. "install: " .. description, vim.log.levels.WARN)
  end

  return should_install
end

---@param bufnr integer
---@param package_name string
---@param install? chris468.config.ShouldInstallTool
---@param callback? fun()
local function install_package(bufnr, package_name, install, callback)
  local function complete()
    raise_filetype(bufnr)
    if callback then
      callback()
    end
  end
  local registry = require("mason-registry")
  local ok, package = pcall(registry.get_package, package_name)
  if not ok or package:is_installed() or not should_install_tool(package_name, install) then
    complete()
    return
  end

  notify("Installing " .. package_name .. "...")
  package
    :once("install:success", function()
      notify("Successfully installed " .. package_name .. ".")
      complete()
    end)
    :once("install:failed", function()
      notify("Error installing " .. package_name .. ".", vim.log.levels.WARN)
    end)
  package:install()
end

local function map_lsps_to_filetypes()
  _ = require("lspconfig")
  local result = vim.defaulttable(function()
    return {}
  end)
  --
  for lsp, _ in pairs(Chris468.tools.lsps) do
    if vim.lsp.config[lsp] then
      for _, filetype in ipairs(vim.lsp.config[lsp].filetypes or {}) do
        table.insert(result[filetype], lsp)
      end
    end
  end

  return result
end

---@param config? vim.lsp.Config
---@return vim.lsp.Config?
local function merge_completion_capabilities(config)
  if require("chris468.util.lazy").has_plugin("blink.cmp") then
    config = config or {}
    config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities, true)
  end

  return config
end

---@param bufnr integer
---@param lsps string[]
local function install_and_enable_lsps(bufnr, lsps)
  for _, lsp in ipairs(lsps) do
    vim.lsp.enable(lsp)
    local lsp_tool = Chris468.tools.lsps[lsp]
    local lsp_config = merge_completion_capabilities(lsp_tool.config)
    if lsp_config then
      vim.lsp.config(lsp, lsp_config)
    end
    install_package(bufnr, lsp_package(lsp), lsp_tool.install)
  end
end

---@param bufnr integer
---@param tools_for_filetype chris468.config.ToolsByFiletype
---@param filetype string
---@param callback? fun(bufnr: integer, tool: chris468.config.ToolSpec)
local function install_tools_for_filetype(bufnr, tools_for_filetype, filetype, callback)
  for _, tool in ipairs(tools_for_filetype[filetype] or {}) do
    tool = type(tool) == "string" and { tool } or tool
    local package = tool[1]
    local install = tool.install
    install_package(bufnr, package, install, function()
      if callback then
        callback(bufnr, tool --[[@as chris468.config.ToolSpec)--]])
      end
    end)
  end
end

local function install_linters(bufnr, filetype)
  install_tools_for_filetype(bufnr, Chris468.tools.linters, filetype)
end

local function install_formatters(bufnr, filetype)
  install_tools_for_filetype(bufnr, Chris468.tools.formatters, filetype, function(b, tool)
    ---@diagnostic disable-next-line: undefined-field
    if tool.format_on_save == false then
      vim.b[b].format_on_save = false
    end
  end)
end

---@type table<string, string[]>
local lsps_by_ft
---@param bufnr integer
---@param filetype string
local function install_tools(bufnr, filetype)
  if not lsps_by_ft then
    lsps_by_ft = map_lsps_to_filetypes()
  end

  if not installed_tools_for_filetype[filetype] then
    installed_tools_for_filetype[filetype] = true
    install_and_enable_lsps(bufnr, lsps_by_ft[filetype])
    install_linters(bufnr, filetype)
    install_formatters(bufnr, filetype)
  end
end

---@param bufnr integer
---@param client vim.lsp.Client
local function configure_inlay_hints(bufnr, client)
  local bufutil = require("chris468.util.buffer")
  if bufutil.valid_normal(bufnr) and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, bufnr) then
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

function M.configure_lsp()
  local group = vim.api.nvim_create_augroup("chris468.tools.lsp", { clear = true })
  register_lsp_attach(group)

  register_dynamic_capability_handlers()
end

function M.configure_tool_install()
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("chris468.tools", { clear = true }),
    callback = function(arg)
      local filetype = arg.match
      if not vim.list_contains(Chris468.tools.disable, filetype) then
        local buf = arg.buf
        return install_tools(buf, filetype)
      end
    end,
  })
end

---@param linters string[]
local function run_installed_linters(linters)
  local installed_linters = vim.tbl_filter(function(v)
    local registry = require("mason-registry")
    local ok, package = pcall(registry.get_package, v)
    return ok and package:is_installed()
  end, linters)

  if #installed_linters > 0 then
    require("lint").try_lint(installed_linters)
  end
end

---@param linters_by_ft table<string, string[]>
function M.register_lint(linters_by_ft)
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
    group = vim.api.nvim_create_augroup("chris468.lint", { clear = true }),
    callback = function()
      local linters = linters_by_ft[vim.bo.filetype] or {}
      run_installed_linters(linters)
    end,
  })
end

return M
