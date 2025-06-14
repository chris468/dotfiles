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

local function get_selection()
  local start = vim.fn.getpos(".")
  local _end = vim.fn.getpos("v")
  if pos_equal(start, _end) then
    return vim.api.nvim_get_current_line()
  end

  return vim.fn.join(vim.fn.getregion(start, _end), "\n")
end

function M.run_selection()
  local selection = get_selection()
  if not selection then
    return
  end

  local ok, fn = pcall(load, selection)
  if not ok then
    vim.notify("Failed to parse selection: " .. fn, vim.log.levels.ERROR)
    return
  end

  local result
  ok, result = pcall(fn --[[ @as function ]])
  if not ok then
    vim.notify("Failed to run selection: " .. result, vim.log.levels.ERROR)
  elseif result then
    vim.notify("Result: " .. vim.inspect(result))
  end
end

return M
