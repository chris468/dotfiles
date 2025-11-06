local ToggleTerm = require("toggleterm.terminal")
local Terminal = require("chris468.util.terminal._terminal"):extend()

function Terminal.toggle(opts)
  opts = opts or { count = 1 }
  opts.name = opts.name or ("Terminal %s"):format(opts.count)
  local t = ToggleTerm.get_or_create_term(opts.count, nil, nil, opts.name)
  t:toggle()
end

return Terminal
