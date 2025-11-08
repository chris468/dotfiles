local lazy_require = require("lazy-require").require_on_index
local toggleterm = lazy_require("toggleterm")

---@class chris468.util.Terminal.ToggleTerminal : chris468.util.Terminal

local ToggleTerminal = require("chris468.util.terminal._terminal"):extend() --[[ @as chris468.util.Terminal.ToggleTerminal ]]

function ToggleTerminal:toggle(opts)
  toggleterm.toggle(opts.count, nil, nil, nil, opts.name or ("Terminal %s"):format(opts.count))
end

function ToggleTerminal:background_command(cmd, opts)
  opts = opts or {}
  opts.display_name = opts.display_name or cmd
  opts = vim.tbl_deep_extend("keep", {
    cmd = cmd,
  }, opts, ToggleTerminal._background_config)

  local t = require("toggleterm.terminal").Terminal:new(opts)
  t:spawn()
end

return ToggleTerminal
