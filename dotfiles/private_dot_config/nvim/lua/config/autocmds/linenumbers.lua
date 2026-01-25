local debounce = require("util.debounce")

local group = vim.api.nvim_create_augroup("chris468.autocmds.linenumbers", { clear = true })

local function getwidth(current_width, lines)
  local magnitude = math.log(lines) / math.log(10)

  local needed_width = math.max(1, math.floor(magnitude) + 1)

  if needed_width > current_width or needed_width - magnitude > 0.05 then
    return needed_width
  end

  return current_width
end

local function get_windows_for_buffer(bufnr)
  return vim.tbl_filter(function(winnid)
    return vim.api.nvim_win_get_buf(winnid) == bufnr
  end, vim.api.nvim_list_wins())
end

local function on_textchanged(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local lines = vim.api.nvim_buf_line_count(bufnr)
  local winids = get_windows_for_buffer(bufnr)
  for _, winid in ipairs(winids) do
    local current_width = vim.wo[winid].numberwidth
    local new_width = getwidth(current_width, lines)
    if new_width ~= current_width then
      vim.wo[winid].numberwidth = new_width
    end
  end
end

vim.api.nvim_create_autocmd("BufWinEnter", {
  callback = function(a)
    on_textchanged(a.buf)
  end,
  group = group,
})

vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TextChangedP", "TextChangedT" }, {
  callback = function(a)
    debounce(250, false, on_textchanged, a.buf)
  end,
  group = group,
})
