local M = {}

function M.start()
  vim.cmd("profile start ~/profile.log")
  vim.cmd("profile func *")
  vim.cmd("profile file *")

  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = vim.api.nvim_create_augroup("chris468.profile", { clear = true }),
    callback = M.stop,
  })
end

function M.stop()
  vim.cmd("profile stop")
  -- vim.cmd("noautocmd qall!")
end

setmetatable(M, { __call = M.start })

return M
