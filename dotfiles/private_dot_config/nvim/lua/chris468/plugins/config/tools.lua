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

---@pram bufnr integer
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
    local registry = require("mason-registry")
    local ok, package = pcall(registry.get_package, v)
    return ok and package:is_installed()
  end, linters)

  if #installed_linters > 0 then
    require("lint").try_lint(installed_linters)
  end
end

---@param linters_by_ft table<string, string[]>
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

---@param opts chris468.config.LspConfig
---@return chris468.config._CachedLspConfig
local function cached_lspconfig_info(opts)
  return setmetatable({}, {
    __index = function(tbl, name)
      local config = opts[name]
      if not config or config.enabled == false then
        tbl[name] = { server_name = name, filetypes = {}, lspconfig = {}, "LSP " .. name }
      else
        local package
        if config.package ~= false then
          local ok, p = pcall(require("mason-registry").get_package, name)
          package = ok and p or nil
        end

        local server_name = config.name or vim.tbl_get(package or {}, "spec", "neovim", "lspconfig") or name
        local filetypes =
          util.make_set((config.lspconfig or {}).filetypes or vim.lsp.config[server_name].filetypes or {})
        local display_name =
          string.format("LSP %s%s", name, name == server_name and "" or string.format("(%s) ", server_name))

        tbl[name] = {
          server_name = server_name,
          filetypes = filetypes,
          package = package,
          lspconfig = config.lspconfig,
          display_name = display_name,
        }
      end

      return tbl[name]
    end,
  })
end

---@param info chris468.config._CachedLspConfig
---@param bufnr integer
local function enable_and_install_lsp(info, bufnr)
  vim.lsp.config(info.server_name, merge_completion_capabilities(info.lspconfig))
  vim.lsp.enable(info.server_name)
  util_mason.install(info.package, function()
    raise_filetype(bufnr)
  end, function()
    vim.lsp.disable(info.server_name)
  end, info.display_name)
end

--- @param opts chris468.config.LspConfig
--- @param group integer
local function lazily_install_lsps_by_filetype(opts, group)
  local _ = require("lspconfig")
  local infos = cached_lspconfig_info(opts)
  local handled_filetypes = util.make_set(Chris468.disable_filetypes)
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function(arg)
      local filetype = arg.match
      if handled_filetypes[filetype] then
        return
      end

      handled_filetypes[filetype] = true

      for name, _ in pairs(opts) do
        local info = infos[name]
        if info.filetypes[filetype] then
          enable_and_install_lsp(info, arg.buf)
        end
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

---@param tools_by_ft chris468.config.FormattersByFileType
---@param disabled_filetypes { [string]: true }
---@return { tools_by_ft: {[string]: string[]}, config_by_ft: {[string]: chris468.config.Formatter[]}}
local function normalize_tools_by_ft(tools_by_ft, disabled_filetypes)
  return vim.iter(tools_by_ft):fold({ tools_by_ft = {}, config_by_ft = {} }, function(result, _, v)
    for ft, tools in pairs(v) do
      if not disabled_filetypes[ft] then
        result.tools_by_ft[ft] = result.tools_by_ft[ft] or {}
        result.config_by_ft[ft] = result.config_by_ft[ft] or {}
        for _, tool in ipairs(tools) do
          local is_string = type(tool) == "string"
          if is_string or tool.enabled ~= false then
            table.insert(result.tools_by_ft[ft], is_string and tool or tool[1])
            table.insert(result.config_by_ft[ft], is_string and { tool } or tool)
          end
        end
      end
    end
    return result
  end)
end

local function cached_tool_info(tool_type)
  local cache = {}
  return function(config)
    local name = config[1]
    if not cache[name] then
      local package
      if config.package ~= false then
        local ok, p = pcall(require("mason-registry").get_package, config.package or name)
        package = ok and p or nil
      end

      local package_name = package and package.spec.name or name
      local display_name =
        string.format("%s %s%s", tool_type, package_name, name == package_name and "" or string.format(" (%s)", name))
      cache[name] = { name = name, package = package, package_name = package_name, display_name = display_name }
    end

    return cache[name]
  end
end

---@param config_by_ft { [string]: chris468.config.Formatter[] }
---@param disabled_filetypes { [string]: true }
---@param tool_type string
local function lazily_install_tools_by_filetype(config_by_ft, disabled_filetypes, tool_type)
  local handled_filetypes = disabled_filetypes
  local cache = cached_tool_info(tool_type)

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("chris468." .. tool_type, { clear = true }),
    callback = function(arg)
      local filetype = arg.match
      if handled_filetypes[filetype] then
        return
      end
      handled_filetypes[filetype] = true

      for _, c in ipairs(config_by_ft[filetype] or {}) do
        local info = cache(c)
        util_mason.install(info.package, function()
          raise_filetype(arg.buf)
        end, nil, info.display_name)
      end
    end,
  })
end

function M.formatter_config(opts)
  local disabled_filetypes = util.make_set(Chris468.disable_filetypes)
  local config = normalize_tools_by_ft(opts.formatters_by_ft, disabled_filetypes)
  require("conform").setup(vim.tbl_extend("keep", { formatters_by_ft = config.tools_by_ft }, opts))
  lazily_install_tools_by_filetype(config.config_by_ft, disabled_filetypes, "formatter")
end

function M.linter_config(opts)
  local disabled_filetypes = util.make_set(Chris468.disable_filetypes)
  local config = normalize_tools_by_ft(opts.linters_by_ft, disabled_filetypes)
  require("lint").linters_by_ft = config.tools_by_ft
  lazily_install_tools_by_filetype(config.config_by_ft, disabled_filetypes, "linter")
  register_lint(config.tools_by_ft)
end

return M
