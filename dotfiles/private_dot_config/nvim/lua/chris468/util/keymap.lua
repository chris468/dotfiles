local wrap = require("chris468.util").wrap

local M = {}

function M.cmd(str)
  return wrap(vim.cmd, str)
end

return M
