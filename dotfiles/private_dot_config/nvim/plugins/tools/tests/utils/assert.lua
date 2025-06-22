local M = {}

---@param assert fun()
---@parm opts { timeout?: integer, interval?: integer, success? : boolean}
function M.wait_for(assert, opts)
  opts = opts or {}
  vim.wait(opts.timeout or 1000, function()
    local ok, _ = pcall(assert)
    if opts.success then
      return not ok
    end
    return ok
  end, opts.interval, false)

  assert()
end

return M
