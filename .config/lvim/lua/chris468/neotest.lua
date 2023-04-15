local M = {}

function M.config()
  lvim.chris468.neotest = {
    adapters = { "neotest-python", "neotest-dotnet" },
  }
end

function M.setup()
  local adapters = {}
  local Log = require('lvim.core.log')

  for _, name in ipairs(lvim.chris468.neotest.adapters) do
    local loaded, adapter = pcall(require, name)
    if loaded then
      adapters[#adapters + 1] = adapter
    else
      Log:warn("Failed to load neotest adapter: " .. name)
    end
  end

  local neotest = require('neotest')
  neotest.setup({
    adapters = adapters
  })
end

return M
