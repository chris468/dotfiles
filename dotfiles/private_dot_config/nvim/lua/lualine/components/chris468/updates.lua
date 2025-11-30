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
    require("lualine").refresh_status()
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
      require("lualine").refresh_status()
    end)
  end
end

function M:init(options)
  M.super.init(self, options)

  ---@type "PENDING"|"READY"
  self.state = "PENDING"
  ---@type integer
  self.outdated = 0

  self:_hook_mason_events()
  self:_count_outdated_mason_packages()

  local _, lazy_hl = require("mini.icons").get("filetype", "lazy")
  self.options.lazy_color = self:create_hl(lazy_hl)

  local mason_icon, mason_hl = require("mini.icons").get("filetype", "mason")
  self.options.mason_icon = mason_icon
  self.options.mason_color = self:create_hl(mason_hl)
end

---@private
---@return string
function M:_mason_status()
  local state, outdated = self.state, self.outdated
  local ready = state == "READY"
  local display = not ready or outdated ~= 0
  if display then
    return self:format_hl(self.options.mason_color)
      .. self.options.mason_icon
      .. " "
      .. (ready and ("%d"):format(outdated) or "…")
  end

  return ""
end

---@private
---@return string
function M:_lazy_status()
  local updates = require("lazy.status").updates()
  if updates then
    return self:format_hl(self.options.lazy_color) .. updates
  end

  return ""
end

function M:update_status()
  local result = table.concat({ self:_mason_status(), self:_lazy_status() }, " ")
  result = result:gsub("%s*$", "")
  return result
end

return M
