local function get_profiles()
  local os = require("os")
  local profile = os.getenv("CHRIS468_LAZYVIM_PROFILE")

  if profile == "defaults" then
    return {}
  end

  local profiles = { "base" }
  if profile and profile ~= "base" then
    profiles[#profiles + 1] = profile
  end

  return profiles
end

local function load_module(profile, config_module)
  local module = "chris468.profiles." .. profile
  if config_module then
    module = module .. ".config." .. config_module
  end
  return require(module)
end
local profiles = get_profiles()

local function foreach_profile(action)
  for _, profile in ipairs(profiles) do
    action(profile)
  end
end

local M = {}
function M.append_specs(specs)
  foreach_profile(function(profile)
    specs[#specs + 1] = load_module(profile)
  end)
end

function M.load_configs(config_module)
  foreach_profile(function(profile)
    load_module(profile, config_module)
  end)
end

return M
