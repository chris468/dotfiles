local M = require("lualine.component"):extend()

function M:_count_outdated_mason_packages()
  local registry = require("mason-registry")
  self.outdated, self.state =
    vim.iter(registry.get_installed_packages()):fold(0, function(count, pkg)
      if pkg:get_installed_version() ~= pkg:get_latest_version() then
        count = count + 1
      end
      return count
    end), "READY"
end

function M:_hook_mason_events()
  local registry = require("mason-registry")
  registry:on("update:start", function()
    self.state = "PENDING"
  end)

  local events = {
    "update:success",
    "update:failed",
    "package:install:success",
    "package:install:failed",
    "package:uninstall:success",
    "package:uninstall:failed",
  }

  for _, event in ipairs(events) do
    registry:on(event, function()
      M._count_outdated_mason_packages(self)
    end)
  end
end

function M:init(options)
  options = options or {}
  options.icon = options.icon or require("mini.icons").get("filetype", "mason")
  M.super.init(self, options)

  ---@type "PENDING"|"READY"
  self.state = "PENDING"
  ---@type integer
  self.outdated = 0

  self:_hook_mason_events()
  self:_count_outdated_mason_packages()
end

function M:update_status()
  local state, outdated = self.state, self.outdated
  local ready = state == "READY"
  local display = not ready or outdated ~= 0

  return display and (ready and ("%d"):format(outdated) or "…") or nil
end

return M
