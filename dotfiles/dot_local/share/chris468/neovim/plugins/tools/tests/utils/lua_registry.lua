local mt = {}
local M = setmetatable({ _setup = false }, mt)

local lazy = {
  names = function()
    return require("tests.utils.lua_registry._packages").names
  end,
}

function mt:__index(key)
  local l = lazy[key]
  if not l then
    return
  end
  self[key] = l()
  return self[key]
end

function M.setup()
  if M._setup then
    error("Already setup")
  end
  M._setup = true
  local mason = require("mason")
  mason.setup({
    PATH = "skip",
    registries = {
      "lua:tests.utils.lua_registry.index",
    },
    providers = {},
  })
  require("mason-registry").refresh()
end

return M
