local M = {}

local function config()
  lvim.chris468 = {}
end

function M.setup()
  config()
  require('chris468.dap').config()
end

return M
