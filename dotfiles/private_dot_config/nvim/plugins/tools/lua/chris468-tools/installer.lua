local M = {}

local function notify(...)
  vim.schedule_wrap(vim.notify)(...)
end

---@generic TConfig
---@generic TTool : chris468.tools.Tool
---@param opts  { [string]: { [string]: TConfig } }
---@param Tool TTool
---@return { [string]: TTool[] } tools_by_ft, { [string] : string[] } names_by_ft
function M.map_tools_by_filetype(opts, Tool)
  local function empty()
    return {}
  end
  local tools_by_ft = vim.defaulttable(empty)
  local names_by_ft = vim.defaulttable(empty)

  for _, configs in pairs(opts) do
    for name, config in pairs(configs) do
      ---@diagnostic disable-next-line: undefined-field
      local tool = Tool:new(name, config)
      if tool.enabled then
        for _, ft in ipairs(tool:filetypes()) do
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
local function install(tool, bufnr)
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
function M.install(tools, bufnr)
  for _, tool in ipairs(tools) do
    if tool:enabled() then
      install(tool, bufnr)
    end
  end
end

return M
