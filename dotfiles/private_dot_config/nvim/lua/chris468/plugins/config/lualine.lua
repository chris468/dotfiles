local M = {
  mason = {
    ---@type "NONE"|"PENDING"|"READY"
    state = "NONE",
    ---@type integer
    outdated = 0,
  },
}

local function count_outdated_mason_packages()
  local registry = require("mason-registry")
  M.mason.outdated, M.mason.state =
    vim.iter(registry.get_installed_packages()):fold(0, function(count, pkg)
      if pkg:get_installed_version() ~= pkg:get_latest_version() then
        count = count + 1
      end
      return count
    end), "READY"
end

local function hook_mason_events()
  local registry = require("mason-registry")
  registry:on("update:start", function()
    M.mason.state = "PENDING"
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
    registry:on(event, count_outdated_mason_packages)
  end
end

local function mason_setup()
  M.mason.state = "PENDING"
  hook_mason_events()
  count_outdated_mason_packages()
end

function M.mason.status()
  if M.mason.state == "NONE" then
    local ok, err = pcall(mason_setup)
    if not ok then
      vim.notify(err --[[ @as string ]], vim.log.levels.ERROR)
    end
  end

  local icon, _ = require("mini.icons").get("filetype", "mason")
  local state, outdated = M.mason.state, M.mason.outdated
  local ready = state == "READY"
  local display = not ready or outdated ~= 0
  return display and icon .. (ready and outdated or "…") or ""
end

function M.mason.cond()
  return M.mason.state ~= "READY" or M.mason.outdated ~= 0
end

function M.mason.color()
  local _, hl = require("mini.icons").get("filetype", "mason")
  return hl
end

return M
