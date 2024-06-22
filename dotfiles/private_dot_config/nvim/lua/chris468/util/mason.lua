local M = {}

--- @class (exact) chris468.util.mason.Tool
--- @field package_name string
--- @field on_complete fun(tool: chris468.util.mason.Tool)?
--- @field data  any?

--- @alias chris468.util.mason.ToolsForFiletype { [string]: (string|chris468.util.mason.Tool)[] }

--- @module "mason-core"
--- @param pkg Package
--- @param callback fun(tool: chris468.util.mason.Tool)
--- @param tool chris468.util.mason.Tool
local function install_tool(pkg, callback, tool)
  vim.notify("Installing " .. pkg.name .. "...")
  pkg:install():once("closed", function()
    if pkg:is_installed() then
      vim.notify("Successfully installed " .. pkg.name .. ".")
    else
      vim.notify("Failed to install " .. pkg.name .. ".", vim.log.levels.WARN)
    end
    vim.schedule_wrap(function()
      callback(tool)
    end)()
  end)
end

local function noop(_) end

--- @param tools (chris468.util.mason.Tool|string)[]
function M.install_tools(tools)
  local registry = require("mason-registry")
  for _, tool in ipairs(tools) do
    if type(tool) == "string" then
      tool = { package_name = tool }
    end
    local on_complete = tool.on_complete or noop
    if registry.is_installed(tool.package_name) then
      on_complete(tool)
      return
    end

    local pkg = registry.get_package(tool.package_name)
    if not pkg then
      vim.notify("Package " .. tool .. " not found", vim.log.levels.ERROR)
      on_complete(tool)
      return
    end

    install_tool(pkg, on_complete, tool)
  end
end

--- @param install_for_filetype chris468.util.mason.ToolsForFiletype
--- @param desc string
function M.lazy_install_for_filetype(install_for_filetype, desc)
  for filetype, tools in pairs(install_for_filetype) do
    vim.api.nvim_create_autocmd("FileType", {
      pattern = filetype,
      callback = function()
        local util = require("chris468.util")
        vim.schedule_wrap(function(_)
          util.mason.install_tools(tools)
        end)()
        return true
      end,
      desc = filetype .. ": " .. desc,
    })
  end
end

return M
