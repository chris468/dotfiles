local neotest = require 'neotest'

local adapter_names = { 'neotest-python', 'neotest-dotnet', }
local adapters = {}
for _, n in ipairs(adapter_names) do
  local present, adapter = pcall(require, n)
  if present then adapters[#adapters + 1] = adapter end
end

local symbols = require 'chris468.util.symbols'
neotest.setup {
  adapters = adapters,
  icons = {
    passed = symbols.passed,
    failed = symbols.failed,
    skipped = symbols.skipped,
    running_animated = symbols.progress_animation,
  }
}
