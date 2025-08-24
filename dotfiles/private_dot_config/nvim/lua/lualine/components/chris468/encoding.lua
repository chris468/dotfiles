local M = require("lualine.components.encoding"):extend()

function M:update_status()
  local encoding = M.super.update_status(self)
  return encoding ~= "utf-8" and encoding or nil
end

return M
