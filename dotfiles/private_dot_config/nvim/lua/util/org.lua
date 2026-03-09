local M = {}
local menu = require("util.ui.menu")
local async = require("plenary.async")
local path_selector = require("util.ui.path_selector")

local session_org_dir
local configured_org_dir
local in_flight

---@return boolean
local function configure_org_path()
  local dir = path_selector.select_path({
    history_key = "org",
    select_prompt = "Select Org notes path",
    input_prompt = "Org notes path: ",
    new_item_label = "Enter new path...",
    create_missing = true,
  })
  if not dir then
    return false
  end

  session_org_dir = dir
  if configured_org_dir == session_org_dir then
    return true
  end

  local ok, err = pcall(require("orgmode").setup, {
    org_agenda_files = { session_org_dir .. "/**/*.org" },
    org_default_notes_file = session_org_dir .. "/inbox.org",
    org_capture_templates = {
      j = {
        description = "Journal",
        target = session_org_dir .. "/journal/%<%Y>/%<%m>.org",
        datetree = {
          tree_type = "day",
        },
        template = "- %U %?",
      },
      t = {
        description = "Task",
        template = "* TODO %?\n %u\n SCHEDULED: %^{Start}t\n DEADLINE: %^{Deadline}t",
      },
    },
  })
  if not ok then
    vim.notify(("Failed to configure orgmode: %s"):format(err), vim.log.levels.ERROR)
    return false
  end

  configured_org_dir = session_org_dir
  return true
end

function M.select_org_path()
  if in_flight ~= nil then
    return
  end

  in_flight = true

  async.run(function()
    local ok, result = pcall(configure_org_path)
    return ok, result
  end, function(stat, ok, result)
    in_flight = nil
    if not stat then
      vim.notify(("Org action failed: %s"):format(ok), vim.log.levels.ERROR)
      return
    end
    if not ok then
      vim.notify(("Org action failed: %s"):format(result), vim.log.levels.ERROR)
    end
  end)
end

---@param data { title?: string, prompt?: string, items?: table[] }
function M.org_menu_handler(data)
  local title = data.title or "Org menu"
  local prompt = data.prompt
  if prompt and prompt == title then
    prompt = nil
  end
  menu.open({
    title = title,
    prompt = prompt,
    items = data.items or {},
    on_error = function(err)
      vim.notify(("Org action failed: %s"):format(err), vim.log.levels.ERROR)
    end,
  })
end

return M
