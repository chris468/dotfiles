local lazy_require = require("lazy-require").require_on_index
local toggleterm = lazy_require("toggleterm")

---@type chris468.util.Terminal
local ToggleTerminal = require("chris468.util.terminal._terminal"):extend()

function ToggleTerminal:toggle(opts)
  toggleterm.toggle(opts.count, nil, nil, nil, opts.name or ("Terminal %s"):format(opts.count))
end

function ToggleTerminal:background_command(cmd, display_name)
  require("chris468.util._terminal").background_command(cmd, display_name)
end

return ToggleTerminal
