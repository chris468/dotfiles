local project_nvim = require("project_nvim")

local M = {}

local total_retries = 4
local retries = total_retries

---Get project.nvim projects with retry
---project.nvim loads the projects asynchronously, and often the dashboard
---is shown before they are loaded. This method will retry after a short delay
---if no projects are returned. The retry will only occur a limited number of times.
---@param callback? fun()
function M.get_recent_projects(callback)
  local retry = callback and retries > 0
  retries = retries - 1
  local projects = project_nvim.get_recent_projects()
  if retry and vim.tbl_isempty(projects) then
    vim.fn.timer_start((4 - retries) * 10, callback)
  end

  return projects
end

return M
