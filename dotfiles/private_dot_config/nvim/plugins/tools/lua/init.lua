local util = require("chris468-tools._util")
local tools = require("chris468-tools")
local M = {}

---@param bufnr integer
local function raise_filetype(bufnr)
  vim.defer_fn(function()
    vim.api.nvim_exec_autocmds("FileType", {
      buffer = bufnr,
    })
  end, 100)
end

---@generic TConfig
---@generic TTool : chris468.tools.Tool
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
---@return chris468.tools.Lsp
local function create_lsp_tool(name, config)
  local Lsp = tools.lsp.Lsp
  return Lsp:new(name, { enabled = config.enabled, package = config.package, lspconfig = config.lspconfig })
end

--- @param opts chris468.config.LspConfig
--- @param group integer
local function lazily_install_lsps_by_filetype(opts, group)
  local _ = require("lspconfig")
  ---@type { [string]: chris468.tools.Lsp[] }?
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

---@param tools_by_ft { [string]: chris468.tools.Tool[] }
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
return M
