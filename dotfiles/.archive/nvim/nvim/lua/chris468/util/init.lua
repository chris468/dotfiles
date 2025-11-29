local M = {}

function M.insert_at_cursor(text)
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line = vim.api.nvim_get_current_line()
  vim.api.nvim_set_current_line(line:sub(0, col) .. text .. line:sub(col + 1))
end

---@param fn fun():any
function M.save_restore_cursor_selection(fn)
  local buffer = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  local marks = { "<", ">" }
  local saved = {}
  saved.marks = vim.tbl_map(function(v)
    return { v, vim.api.nvim_buf_get_mark(buffer, v) }
  end, marks)
  saved.cursor = vim.api.nvim_win_get_cursor(win)

  local ok, ret = pcall(fn)

  vim.api.nvim_win_set_cursor(win, saved.cursor)
  for _, mark in ipairs(saved.marks) do
    vim.api.nvim_buf_set_mark(buffer, mark[1], mark[2][1], mark[2][2], {})
  end

  if not ok then
    error(ret)
  end

  return ret
end

function M.wrap(fn, ...)
  local params = { ... }

  return function()
    fn(unpack(params))
  end
end

---@param list any[]
---@return table<any, true>
function M.make_set(list)
  return vim.iter(list):fold({}, function(result, v)
    result[v] = true
    return result
  end)
end

return M
