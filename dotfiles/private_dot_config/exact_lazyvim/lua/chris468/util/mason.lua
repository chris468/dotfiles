local registry = require("mason-registry")

local M = {}

---@alias InstallState "already_installed" | "not_found" | "installed" | "failed"

---comment
---@param package_name string
---@param callback fun(status: InstallState)
function M.install(package_name, callback)
  callback = callback or function() end
  if registry.is_installed(package_name) then
    callback("already_installed")
    return
  end

  local pkg = registry.get_package(package_name)
  if not pkg then
    callback("not_found")
    return
  end

  vim.notify("Installing " .. pkg.name .. "...")
  pkg:install():once("closed", function()
    if pkg:is_installed() then
      vim.notify("Successfully installed " .. pkg.name .. ".")
      vim.schedule(function()
        callback("installed")
      end)
    else
      callback("failed")
      vim.notify("Failed to install " .. pkg.name .. ".", vim.log.levels.WARN)
    end
  end)
end

return M
