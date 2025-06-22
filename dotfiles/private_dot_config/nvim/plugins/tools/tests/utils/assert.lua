local M = {}

---@param assert fun()
---@parm opts { timeout?: integer, interval?: integer}
function M.wait_for(assert, opts)
  opts = opts or {}
  vim.wait(opts.timeout or 1000, function()
    local ok, _ = pcall(assert)
    return ok
  end, opts.interval)

  assert()
end

return M
