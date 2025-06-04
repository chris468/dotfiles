local M = {}

function M.schedule_notify(message, level, opts)
  vim.schedule(function()
    vim.notify(message, level, opts)
  end)
end

function M.insert_at_cursor(text)
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  vim.api.nvim_set_current_line(line:sub(0, col) .. text .. line:sub(col + 1))
end

function M.wrap(fn, ...)
  local params = { ... }

  return function()
    fn(unpack(params))
  end
end

return M
