local util = require("chris468.util")

local M = {}

local function noop() end

---@module "mason-core.package"

---@param package? Package|false The package to install. If nil or false, assume already installed and run the callback.
---@param installed_callback? fun() Called if the package is already or successfully installed
---@param failed_callback? fun() Called if the install fails
---@param display? string Display name to use in notifiecations. Defaults to package name.
function M.install(package, installed_callback, failed_callback, display)
  installed_callback = installed_callback or noop
  failed_callback = failed_callback or noop
  if package and not package:is_installed() then
    display = display or package.spec.name
    util.schedule_notify(string.format("Installing %s...", display))
    package
      :once("install:success", function()
        util.schedule_notify(string.format("Successfully installed %s.", display))
        installed_callback()
      end)
      :once("install:failed", function()
        util.schedule_notify(string.format("Error installing %s.", display), vim.log.levels.WARN)
        failed_callback()
      end)
    package:install()
  else
    installed_callback()
  end
end

return M
