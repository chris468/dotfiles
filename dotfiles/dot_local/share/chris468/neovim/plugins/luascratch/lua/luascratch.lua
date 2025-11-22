local layout = require("luascratch.layout")

local M = {}

function M.toggle()
  layout:toggle()
end

---@param opts chris468.luascratch.config
function M.setup(opts)
  require("luascratch.config").setup(opts)
end

return M
