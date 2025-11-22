local layout = require("luascratch.layout")
local run = require("luascratch.run")

---@class chris468.luascratch.actions
local M = {}

function M.input()
  if not layout:valid() then
    return
  end
  layout:focus_input()
end

function M.output()
  if not layout:valid() then
    return
  end

  layout:toggle_output(true)
  layout:focus_output()
end

function M.hide_output()
  if not layout:valid() then
    return
  end

  layout:toggle_output(false)
end

local function append_to_output(...)
  if not layout:valid() then
    return
  end

  local function _append(lines)
    layout:toggle_output(true)
    local buf = layout:output_buf()

    local start = -1
    if not vim.b[buf].chris468_luascratch_written then
      vim.b[buf].chris468_luascratch_written = true
      start = 0
    end

    vim.bo[buf].modifiable = true
    local ok, err = pcall(vim.api.nvim_buf_set_lines, buf, start, -1, false, lines)
    vim.bo[buf].modifiable = false
    if not ok then
      error(err)
    end
  end

  local lines = vim.split(
    table.concat(
      vim.tbl_map(function(v)
        return type(v) == "string" and v or vim.inspect(v)
      end, { ... }),
      " "
    ),
    "\n"
  )
  vim.schedule_wrap(_append)(lines)
end

function M.run()
  if not layout:input_valid() then
    return
  end

  run(layout:input_win(), append_to_output)
end

function M.run_current_line()
  if not layout:input_valid() then
    return
  end

  run(layout:input_win(), append_to_output, true)
end

function M.clear_output()
  if not layout:output_valid() then
    return
  end

  local buf = layout:output_buf()
  vim.bo[buf].modifiable = true
  local ok, err = pcall(vim.api.nvim_buf_set_lines, buf, 0, -1, false, {})
  vim.bo.modifiable = false
  if not ok then
    error(err)
  end
  vim.b[buf].chris468_luascratch_written = false
  layout:toggle_output(false)
end

return M
