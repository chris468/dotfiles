M = {}

M.map = function(mappings)
  for _, m in pairs(mappings) do
    if not m.map or not m.cmd then
      print('map and cmd are required. skipping ' .. vim.inspect(m))
    else
      vim.keymap.set(
        m.mode or "n",
        m.map,
        m.cmd,
        m.opts or { noremap = true, silent = true }
      )
    end
  end
end

M.temporarily_disable_relativenumber = function()
  local win = vim.wo[vim.api.nvim_get_current_win()]
  local old = win.relativenumber
  win.relativenumber = false
  local timer = vim.loop.new_timer()
  timer:start(
    2000,
    0,
    vim.schedule_wrap(
      function()
        win.relativenumber = old
      end
    )
  )
end

local if_ext = require 'chris468.util.if-ext'
M.ext = function(name, callback)
  return function()
    if_ext(name, function(e)
      callback(e)
    end)
  end
end

return M
