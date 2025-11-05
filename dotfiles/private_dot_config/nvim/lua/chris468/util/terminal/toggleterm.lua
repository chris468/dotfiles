local toggleterm = require("toggleterm")
local Terminal = require("chris468.util.terminal._terminal"):extend()

function Terminal.toggle(opts)
  opts = opts or { count = 1 }
  opts.name = opts.name or ("Terminal %s"):format(opts.count)
  toggleterm.toggle(opts.count, nil, nil, nil, opts.name)
end

return Terminal
