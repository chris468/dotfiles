local M = {}
function M.schedule_notify(message, level, opts)
  vim.schedule(function()
    vim.notify(message, level, opts)
  end)
end

return M
