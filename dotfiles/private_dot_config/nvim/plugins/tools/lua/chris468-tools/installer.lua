local util = require("chris468-tools._util")

local M = {}

local function notify(...)
  vim.schedule_wrap(vim.notify)(...)
end

---@generic TConfig
---@generic TTool : chris468.tools.Tool
---@param opts  { [string]: TConfig }
---@param Tool TTool
---@param disabled_filetypes string[]
---@return { [string]: TTool[] } tools_by_ft, { [string] : string[] } names_by_ft
function M.map_tools_by_filetype(opts, Tool, disabled_filetypes)
  disabled_filetypes = util.make_set(disabled_filetypes or {})
  local function empty()
    return {}
  end
  local tools_by_ft = vim.defaulttable(empty)
  local names_by_ft = vim.defaulttable(empty)

  for name, config in pairs(opts) do
    ---@diagnostic disable-next-line: undefined-field
    local tool = Tool:new(name, config)
    if tool.enabled then
      for _, ft in ipairs(tool:filetypes()) do
        if not disabled_filetypes[ft] then
          table.insert(tools_by_ft[ft], tool)
          table.insert(names_by_ft[ft], tool:name())
        end
      end
    end
  end

  return tools_by_ft, names_by_ft
end

---@module "mason-core.package"

---@param tool chris468.tools.Tool The tool to install.
---@param bufnr integer buffer that triggered the install
local function install_tool(tool, bufnr)
  tool:before_install()

  local package = tool:package()
  if package and not package:is_installed() then
    local display = tool:display_name()
    notify(string.format("Installing %s...", display))
    package
      :once("install:success", function()
        notify(string.format("Successfully installed %s.", display))
        tool:on_installed(bufnr)
      end)
      :once("install:failed", function()
        notify(string.format("Error installing %s.", display), vim.log.levels.WARN)
        tool:on_install_failed(bufnr)
      end)
    package:install()
  else
    tool:on_installed(bufnr)
  end
end

---@param tools chris468.tools.Tool[]
---@param bufnr integer buffer that triggered the install
local function install_tools(tools, bufnr)
  for _, tool in ipairs(tools) do
    if tool.enabled then
      install_tool(tool, bufnr)
    end
  end
end

---@param tools_by_ft { [string]: chris468.tools.Tool[] }
---@param augroup integer
function M.install_on_filetype(tools_by_ft, augroup)
  local handled_filetypes = {}

  vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    callback = function(arg)
      local filetype = arg.match
      if handled_filetypes[filetype] or not tools_by_ft[filetype] then
        return
      end
      handled_filetypes[filetype] = true

      install_tools(tools_by_ft[filetype], arg.buf)
    end,
  })
end

return M
