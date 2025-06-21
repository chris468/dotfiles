local Object = require("plenary").class
---@class FakeRegistry
local FakeRegistry = Object:extend()
FakeRegistry._packages = {}
FakeRegistry._original_registry = false

function FakeRegistry:get_package(name)
  if type(self) == "string" then
    if not Object.is(package.loaded["mason-registry"], FakeRegistry) then
      error("Not registered")
    end
    name = self
    self = package.loaded["mason-registry"] --[[ @as FakeRegistry ]]
  end

  if not self._packages[name] then
    error("package " .. name .. " not found")
  end
  return self._packages[name]
end

function FakeRegistry:add_package(name, package)
  self._packages[name] = vim.tbl_deep_extend("error", { spec = { name = name } }, package or {})
  return self._packages[name]
end

function FakeRegistry:remove_package(name)
  self._packages[name] = nil
end

function FakeRegistry:clear()
  self._packages = {}
end

function FakeRegistry:register()
  if self._original_registry ~= false then
    error("Already registered")
  end
  self._original_registry = package.loaded["mason-registry"]
  package.loaded["mason-registry"] = self
end

function FakeRegistry:unregister()
  if package.loaded["mason-registry"] ~= self then
    error("not registered")
  end
  package.loaded["mason-registry"] = self._original_registry or nil
  self._original_registry = false
end

return FakeRegistry
