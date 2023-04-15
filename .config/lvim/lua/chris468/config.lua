local M = {}

local function config()
  lvim.chris468 = {}
end

function M.setup()
  config()
  require('chris468.dap').config()
  require('chris468.plugins').config()
end

return M
