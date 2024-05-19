local config = require("chris468.profiles.config")

local function load_module(profile, config_module)
  local module = "chris468.profiles." .. profile
  if config_module then
    module = module .. ".config." .. config_module
  end
  return require(module)
end

local function foreach_profile(action)
  for profile, enabled in pairs(config.profiles) do
    if enabled then
      action(profile)
    end
  end
end

local M = {}

function M.load_configs(config_module)
  foreach_profile(function(profile)
    load_module(profile, config_module)
  end)
end

return M
