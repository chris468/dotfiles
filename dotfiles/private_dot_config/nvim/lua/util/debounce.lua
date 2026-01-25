local mt = {}

local M = {}

local timers = {}

vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(a)
    vim.iter(timers):each(function(_, v)
      local timer = v[a.buf]
      v[a.buf] = nil
      if timer then
        timer:close()
      end
    end)
  end,
  group = vim.api.nvim_create_augroup("chris468.util.debounce", { clear = true }),
})

---@param timeout number
---@param immediate boolean Run immediately if it's the first call
---@param callback fun(bufnr: number, ...)
---@param bufnr number
function M.debounce(timeout, immediate, callback, bufnr, ...)
  bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr
  timers[callback] = timers[callback] or {}
  if not timers[callback][bufnr] then
    timers[callback][bufnr] = vim.uv.new_timer()
  else
    immediate = false
  end
  local timer = timers[callback][bufnr]

  if immediate then
    callback(bufnr, ...)
  else
    local args = { ... }
    timer:start(timeout, 0, function()
      vim.schedule_wrap(callback)(bufnr, unpack(args))
    end)
  end
end

function mt.__call(t, ...)
  return t.debounce(...)
end

return setmetatable(M, mt)
