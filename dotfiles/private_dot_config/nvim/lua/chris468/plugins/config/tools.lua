local util = require("chris468.util")
local util_mason = require("chris468.util.mason")
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
  if require("chris468.util.lazy").has_plugin("blink.cmp") then
    config = config or {}
    config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities, true)
  end

  return config
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

---@param tool LspTool
---@param bufnr integer
local function enable_and_install_lsp(tool, bufnr)
  vim.lsp.config(tool:name(), merge_completion_capabilities(tool.lspconfig))
  vim.lsp.enable(tool:name())
  util_mason.install(tool:package(), function()
    raise_filetype(bufnr)
  end, function()
    vim.lsp.disable(tool:name())
  end, tool:display_name())
end

---@generic TConfig
---@generic TTool : BaseTool
---@param opts  { [string]: { [string]: TConfig } }
---@param create_tool fun(name: string,config: TConfig) : TTool
---@return { [string]: TTool }
local function map_tools_by_filetype(opts, create_tool)
  local result = vim.defaulttable(function()
    return {}
  end)
  for _, configs in pairs(opts) do
    for name, config in pairs(configs) do
      local tool = create_tool(name, config)
      if tool.enabled then
        for _, ft in ipairs(tool:filetypes()) do
          table.insert(result[ft], tool)
        end
      end
    end
  end

  return result
end

---@param name string
---@param config chris468.config.LspServer
---@return LspTool
local function create_lsp_tool(name, config)
  local LspTool = require("chris468.plugins.config.tools.tool").LspTool
  return LspTool:new(name, { enabled = config.enabled, package = config.package, lspconfig = config.lspconfig })
end

--- @param opts chris468.config.LspConfig
--- @param group integer
local function lazily_install_lsps_by_filetype(opts, group)
  local _ = require("lspconfig")
  ---@type { [string]: LspTool[] }?
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

      for _, tool in ipairs(lsps_by_ft[filetype] or {}) do
        enable_and_install_lsp(tool, arg.buf)
      end
    end,
  })
end

--- @param opts chris468.config.LspConfig
function M.lspconfig(opts)
  local group = vim.api.nvim_create_augroup("chris468.tools.lsp", { clear = true })
  register_lsp_attach(group)
  register_dynamic_capability_handlers()
  lazily_install_lsps_by_filetype(opts, group)
end

---@param tools_by_ft { [string]: BaseTool[] }
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

      for _, tool in ipairs(tools_by_ft[filetype] or {}) do
        util_mason.install(tool:package(), function()
          raise_filetype(arg.buf)
        end, nil, tool:display_name())
      end
    end,
  })
end

---@param type string
local function create_tool(type)
  ---@param name string
  ---@param config chris468.config.Tool
  ---@return Tool
  return function(name, config)
    local Tool = require("chris468.plugins.config.tools.tool").Tool
    return Tool:new(
      type,
      name,
      { enabled = config.enabled, package = config.package, filetypes = config.filetypes, tool_name = config.name }
    )
  end
end

---@param tools_by_ft { [string]: Tool[] }
local function map_names_by_ft(tools_by_ft)
  local result = vim.defaulttable(function()
    return {}
  end)
  for ft, tools in pairs(tools_by_ft) do
    for _, tool in ipairs(tools) do
      result[ft][tool:name()] = true
    end
  end
  for ft, names in pairs(result) do
    result[ft] = vim.tbl_keys(names)
  end
  return result
end

---@param opts { [string]: { [string]: chris468.config.Tool } }
function M.formatter_config(opts)
  local disabled_filetypes = util.make_set(Chris468.disable_filetypes)
  local tools = map_tools_by_filetype(opts.formatters, create_tool("formatter"))
  require("conform").setup(vim.tbl_extend("keep", { formatters_by_ft = map_names_by_ft(tools) }, opts))
  lazily_install_tools_by_filetype(tools, disabled_filetypes, "formatter")
end

function M.linter_config(opts)
  local disabled_filetypes = util.make_set(Chris468.disable_filetypes)
  local tools = map_tools_by_filetype(opts.linters, create_tool("linter"))
  require("lint").linters_by_ft = map_names_by_ft(tools)
  lazily_install_tools_by_filetype(tools, disabled_filetypes, "linter")
  register_lint(tools)
end

return M
