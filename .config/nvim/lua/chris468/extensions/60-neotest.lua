local if_ext = require 'chris468.util.if-ext'
if_ext ('neotest', function(neotest)
  local adapter_names = { 'neotest-python', 'neotest-dotnet', }
  local adapters = {}
  for _, n in ipairs(adapter_names) do
    if_ext(n, function(a) adapters[#adapters + 1] = a end)
  end

  neotest.setup {
    adapters = adapters,
    icons = {
      passed = '\u{2714}', -- '✔ '
      failed = '\u{2717}', -- '✗ '
      skipped = '\u{25ec}', -- '◬',
      running_animated = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
    }
  }
end)
