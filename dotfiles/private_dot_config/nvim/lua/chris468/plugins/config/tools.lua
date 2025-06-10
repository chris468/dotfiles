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

---@class chris468.config._CachedToolConfig
---@field tool_name string
---@field filetypes { [string]: true }
---@field public package? Package
---@field display_name string

---@class chris468.config._ToolCache
---@field get fun(name: string) : chris468.config._CachedToolConfig
---@field by_ft fun() : {[string]: string[]}

---@param tools { [string]: { [string]: chris468.config.Tool } }
---@param tool_type string
---@param disabled_file_types table<string, true>
---@param additional_properties? string[] Additional properties to cache
---@param look_up_filetypes? fun(name: string, tool_name: string, tool: chris468.config.Tool) : string[]
---@return chris468.config._ToolCache
function M.cached_tool_info(tools, tool_type, disabled_file_types, additional_properties, look_up_filetypes)
  additional_properties = additional_properties or {}
  look_up_filetypes = look_up_filetypes or function() end
  local cache = {}
  local by_ft
  local m = {}

  function m.get(name)
    if not cache[name] then
      local tool
      for _, v in pairs(tools) do
        if v[name] then
          print("found " .. name)
          if tool then
            tool = vim.tbl_extend("keep", tool, v[name])
            tool.filetypes = vim.list_extend(tool.filetypes or {}, v[name].filetypes or {})
          else
            tool = vim.deepcopy(v[name])
          end
        end
      end

      if not tool or tool.enabled == false then
        vim.notify("no tool " .. name)
        cache[name] = { tool_name = name, filetypes = {}, string.format("%s %s", tool_type, name) }
      else
        local package
        if tool.package ~= false then
          local ok, p = pcall(require("mason-registry").get_package, name)
          package = ok and p or nil
        end

        local tool_name = tool.name or vim.tbl_get(package or {}, "spec", "neovim", "lspconfig") or name
        local filetypes = util.make_set(tool.filetypes or look_up_filetypes(name, tool_name, tool) or {})
        local display_name =
          string.format("%s %s%s", tool_type, name, name == tool_name and "" or string.format("(%s) ", tool_name))
        local tool_cache = {
          tool_name = tool_name,
          filetypes = filetypes,
          package = package,
          display_name = display_name,
        }
        for _, k in ipairs(additional_properties) do
          tool_cache[k] = tool[k]
        end

        cache[name] = tool_cache
      end
    end

    return cache[name]
  end

  function m.by_ft()
    if not by_ft then
      by_ft = {}
      local visited = {
        tools = {},
        fts = {},
      }
      for _, v in pairs(tools) do
        for name, _ in pairs(v) do
          if not visited.tools[name] then
            visited.tools[name] = true
            local tool = m.get(name)
            for ft, _ in pairs(tool.filetypes) do
              if not disabled_file_types[ft] and not visited.fts[ft][tool] then
                visited.fts[ft][tool] = true
                by_ft[ft] = by_ft[ft] or {}
                table.insert(by_ft[ft], tool.tool_name)
              end
            end
          end
        end
      end
    end

    return by_ft
  end

  return m
end

local function cached_lspconfig_info(opts, disabled_filetypes)
  return M.cached_tool_info({ lsp = opts }, "LSP", disabled_filetypes, { "lspconfig" }, function(_, server_name, tool)
    return vim.tbl_get(tool, "lspconfig", "filetypes") or vim.lsp.config[server_name].filetypes
  end)
end

---@param info chris468.config._CachedToolConfig|{ lspconfig: vim.lsp.Config }
---@param bufnr integer
local function enable_and_install_lsp(info, bufnr)
  vim.lsp.config(info.tool_name, merge_completion_capabilities(info.lspconfig))
  vim.lsp.enable(info.tool_name)
  util_mason.install(info.package, function()
    raise_filetype(bufnr)
  end, function()
    vim.lsp.disable(info.tool_name)
  end, info.display_name)
end

--- @param opts chris468.config.LspConfig
--- @param group integer
local function lazily_install_lsps_by_filetype(opts, group)
  local _ = require("lspconfig")
  local handled_filetypes = util.make_set(Chris468.disable_filetypes)
  local infos = cached_lspconfig_info(opts, handled_filetypes)
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function(arg)
      local filetype = arg.match
      if handled_filetypes[filetype] then
        return
      end

      handled_filetypes[filetype] = true

      for name, _ in pairs(opts) do
        local info = infos.get(name)
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

---@param cache chris468.config._ToolCache
---@param disabled_filetypes { [string]: true }
---@param tool_type string
local function lazily_install_tools_by_filetype(cache, disabled_filetypes, tool_type)
  local handled_filetypes = disabled_filetypes

  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("chris468." .. tool_type, { clear = true }),
    callback = function(arg)
      local filetype = arg.match
      if handled_filetypes[filetype] then
        return
      end
      handled_filetypes[filetype] = true

      for _, c in ipairs(cache.by_ft()[filetype] or {}) do
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
  local cache = M.cached_tool_info(opts.formatters, "formatter", disabled_filetypes)
  require("conform").setup(vim.tbl_extend("keep", { formatters_by_ft = cache.by_ft() }, opts))
  lazily_install_tools_by_filetype(cache, disabled_filetypes, "formatter")
end

function M.linter_config(opts)
  local disabled_filetypes = util.make_set(Chris468.disable_filetypes)
  local cache = M.cached_tool_info(opts.linters, "linter", disabled_filetypes)
  register_lint(cache.by_ft())
  lazily_install_tools_by_filetype(cache, disabled_filetypes, "linter")
end

return M
