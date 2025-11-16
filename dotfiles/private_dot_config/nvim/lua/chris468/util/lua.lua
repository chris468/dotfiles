local M = {}

local function pos_equal(l, r)
  if #l ~= #r then
    return false
  end
  for i, _ in ipairs(l) do
    if l[i] ~= r[i] then
      return false
    end
  end

  return true
end

local function get_selection(win, current_line)
  if not win or win == 0 then
    win = vim.api.nvim_get_current_win()
  end
  local buf = vim.api.nvim_win_get_buf(win)

  local s, e = 1, -1
  if current_line then
    s = vim.api.nvim_win_get_cursor(win)[1]
    e = s
  else
    local mode = vim.fn.mode()
    if mode == "v" or mode == "V" then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("normal! " .. mode)
      end)
      s = vim.api.nvim_buf_get_mark(0, "<")[1]
      e = vim.api.nvim_buf_get_mark(0, ">")[1]
    end
  end

  local lines = vim.api.nvim_buf_get_lines(buf, s - 1, e, false)
  return table.concat(lines, "\n")
end

---@param win? integer
---@param on_print function(...any)
---@param current_line? boolean
function M.run(win, on_print, current_line)
  local selection = get_selection(win, current_line)
  if not selection then
    return
  end

  local ok, fn = pcall(load, selection)
  if not ok then
    vim.notify("Failed to parse selection: " .. fn, vim.log.levels.ERROR)
    return
  end
  ---@cast fn function

  local env = { print = on_print }
  package.seeall(env)
  setfenv(fn, env)

  local result
  ok, result = pcall(fn)
  if not ok then
    vim.notify("Failed to run selection: " .. result, vim.log.levels.ERROR)
  elseif result then
    vim.notify("Result: " .. vim.inspect(result))
  end
end

return M
