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

local function notify(message, level, opts)
  vim.schedule(function()
    vim.notify(message, level, opts)
  end)
end

---@param bufnr integer
local function raise_filetype(bufnr)
  vim.defer_fn(function()
    vim.api.nvim_exec_autocmds("FileType", {
      buffer = bufnr,
    })
  end, 100)
end

---@param package_name string
---@param prerequisite? chris468.config.CheckPrequisite
---@return boolean
local function check_prerequisite(package_name, prerequisite)
  prerequisite = prerequisite or function()
    return true, ""
  end

  local can_install, description = prerequisite()
  if not can_install then
    notify("Missing prerequisite for " .. package_name .. ": " .. description, vim.log.levels.WARN)
  end

  ---@diagnostic disable-next-line: return-type-mismatch
  return can_install
end

---@param bufnr integer
---@param package_name string
---@param prerequisite? chris468.config.CheckPrequisite
---@param callback? fun()
local function install_package(bufnr, package_name, prerequisite, callback)
  local function complete()
    raise_filetype(bufnr)
    if callback then
      callback()
    end
  end
  local registry = require("mason-registry")
  local ok, package = pcall(registry.get_package, package_name)
  if not ok or package:is_installed() or not check_prerequisite(package_name, prerequisite) then
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

---@param filetype string
local function lsps_for_filetype(lsps, filetype)
  local _ = require("lspconfig")
  local function iter(tbl, key)
    local next_key, config = next(tbl, key)
    while next_key and not vim.list_contains(vim.lsp.config[next_key].filetypes or {}, filetype) do
      next_key, config = next(tbl, next_key)
    end

    return next_key, config
  end

  return iter, lsps
end

---@param config? lspconfig.Config
---@return lspconfig.Config?
local function merge_completion_capabilities(config)
  if require("chris468.lazy").has_plugin("blink.cmp") then
    config = config or {}
    config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
  end

  return config
end

---@param bufnr integer
---@param filetype string
local function install_and_enable_lsps(bufnr, filetype)
  for lsp, config in lsps_for_filetype(Chris468.tools.lsps, filetype) do
    vim.lsp.enable(lsp)
    local lsp_config = merge_completion_capabilities(config.config)
    if lsp_config then
      vim.lsp.config(lsp, lsp_config)
    end
    install_package(bufnr, lsp_package(lsp), config.prerequisite)
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
    local prerequisite = tool.prerequisite
    install_package(bufnr, package, prerequisite, function()
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

---@param bufnr integer
---@param filetype string
function M.install_tools(bufnr, filetype)
  if not installed_tools_for_filetype[filetype] then
    installed_tools_for_filetype[filetype] = true
    install_and_enable_lsps(bufnr, filetype)
    install_linters(bufnr, filetype)
    install_formatters(bufnr, filetype)
  end
end

return M
