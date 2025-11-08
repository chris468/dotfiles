local toggleterm = require("toggleterm")

---@class chris468.util.Terminal
local ToggleTerminal = require("chris468.util.terminal._terminal"):extend()

function ToggleTerminal:toggle(opts)
  toggleterm.toggle(opts.count, nil, nil, nil, opts.name or ("Terminal %s"):format(opts.count))
end

return ToggleTerminal
