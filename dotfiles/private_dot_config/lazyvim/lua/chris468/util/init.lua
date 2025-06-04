local Popup = require("nui.popup")
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

---Merge tables w/ list values into a single table
---For example {a={1},b={2}}+{a={3},b={4,5}} -> {a={1,3}, b={3,4,5}}
---@param ... table<any,any[]>[]
---@return table<any,any[]>
function M.merge_list_maps(...)
  local result = {}
  for _, m in ipairs({ ... }) do
    for k, v in pairs(m) do
      result[k] = result[k] or {}
      vim.list_extend(result[k], v)
    end
  end

  return result
end

---Invert a map where the values are lists.
---For example {a={"x","y"}, b={"y","z"}} => {x={"a"},y={"a","b"},z={"b"}}
---@param t table<string, string[]>
---@return table<string, string[]>
function M.invert_list_map(t)
  local i = {}
  for k, v in pairs(t) do
    for _, ik in ipairs(v) do
      i[ik] = i[ik] or {}
      i[ik][k] = true
    end
  end

  for k, v in pairs(i) do
    i[k] = vim.tbl_keys(v)
  end
  return i
end

---Show content in a readonly popup
---@param content string|string[]
---@param opts table|nil
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
