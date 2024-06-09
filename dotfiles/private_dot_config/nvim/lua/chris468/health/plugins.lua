local lsmod = require("lazy.core.util").lsmod
local M = {}

local function check_load_module(name, display_name)
  local ok, m = pcall(require, name)
  if not ok then
    vim.health.error("Failed to load " .. display_name)
    return
  end

  if type(m) ~= "table" then
    vim.health.error(name .. "did not return a table")
    return
  end

  vim.health.ok("Loaded " .. display_name)

  if type(m[1]) == "string" then
    m = { m }
  end

  return m
end

local function check_laziness(spec, display_name)
  local lazy_keys = { "cmd", "event", "keys" }
  local has_keys = {}
  for _, k in ipairs(lazy_keys) do
    if spec[k] ~= nil then
      table.insert(has_keys, k)
    end
  end

  local is_lazy = spec.lazy == nil or spec.lazy

  local report = (is_lazy == (#has_keys ~= 0)) and vim.health.ok
    or function(msg)
      vim.health.info("   " .. msg)
    end

  report(
    display_name
      .. (is_lazy and " is" or " is not")
      .. " lazy and has "
      .. (#has_keys == 0 and "no " or "")
      .. "lazy configuration"
      .. (#has_keys == 0 and "." or ": ")
      .. table.concat(has_keys, ", ")
  )
end

local function check_plugin(index, plugin, display_name)
  if plugin[1] then
    vim.health.ok(display_name .. " plugin[" .. index .. "] is " .. plugin[1])
  else
    vim.health.error(display_name .. " plugin[" .. index .. "] is  missing plugin")
  end

  check_laziness(plugin, display_name .. "/" .. (plugin[1] or ""))
end

function M.check()
  vim.health.start("plugin configuration")
  lsmod("chris468.plugins", function(name, path)
    local display_name = name .. " (" .. path .. ")"
    local m = check_load_module(name, display_name)
    if not m then
      return
    end

    for index, plugin in ipairs(m) do
      check_plugin(index, plugin, name)
    end
  end)
end

return M
