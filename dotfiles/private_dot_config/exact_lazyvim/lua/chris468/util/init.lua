local Popup = require("nui..popup")
local event = require("nui.utils.autocmd").event

local M = {}

---Split a multiline string into a list of lines
---@param str string
---@return string[]
function M.split_lines(str)
  local lines = {}
  for line in str:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end

  return lines
end

---Show content in a readonly popup
---@param content string|string[]
---@param opts? table
function M.show_in_readonly_popup(content, opts)
  local default_opts = {
    border = {
      style = "rounded",
    },
    buf_options = {
      modifiable = false,
      readonly = true,
    },
    enter = true,
    focusable = true,
    position = "50%",
    relative = "editor",
    size = {
      width = "80%",
      height = "80%",
    },
  }
  opts = vim.tbl_deep_extend("force", default_opts, opts or {})

  if type(content) == "string" then
    content = M.split_lines(content)
  end

  local popup = Popup(opts)

  local function close()
    popup:unmount()
  end

  popup:map("n", "q", close)
  vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, true, content)
  popup:mount()
  vim.api.nvim_set_current_win(popup.winid)
  vim.cmd.stopinsert()
  popup:on(event.BufLeave, close, { once = true })
end

return M
