local M = {}

local function config()
  lvim.chris468 = {}
end

function M.setup()
  config()
  require('chris468.config.dap').config()
  require('chris468.config.plugins').config()
end

return M
