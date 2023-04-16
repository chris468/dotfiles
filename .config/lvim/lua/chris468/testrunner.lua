local M = {}

local function load_adapter(adapter_name)
  local loaded, adapter = pcall(require, adapter_name)
  if not loaded then
    local Log = require('lvim.core.log')
    Log:warn("Failed to load neotest adapter: " .. adapter_name .. "\n" .. adapter)
  end

  return loaded and adapter or nil
end

function M.config()
  lvim.chris468.testrunner = {
    adapters = {},
  }
end

function M.setup()
  local adapters = {}

  for _, name in ipairs(lvim.chris468.testrunner.adapters) do
    local adapter = load_adapter(name)
    if adapter then
      local opts = lvim.chris468.testrunner[name] or {}
      adapters[#adapters + 1] = adapter(opts)
    end
  end

  local neotest = require('neotest')
  neotest.setup({
    adapters = adapters
  })
end

return M
