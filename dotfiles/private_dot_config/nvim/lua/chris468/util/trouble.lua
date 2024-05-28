local M = {}

--- @param mode string
--- @return function
function M.open(mode)
  return function()
    local trouble = require("trouble")
    trouble.open(mode)
  end
end

--- @param mode string?
--- @return function
function M.toggle(mode)
  return function()
    local trouble = require("trouble")
    trouble.toggle(mode)
  end
end

return M
