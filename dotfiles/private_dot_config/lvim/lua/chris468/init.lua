local M = {}

function M.config()
  lvim.chris468 = {}
  require('chris468.dap').config()
  require('chris468.testrunner').config()
  require('chris468.plugins').config()
end

return M
