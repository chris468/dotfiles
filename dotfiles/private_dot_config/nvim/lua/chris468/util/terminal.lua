local M = {}

local callbacks = {}

local function should_show_stdout(str)
  local patterns = {
    "\27%[?[0-9;]*[a-zA-Z]", -- console code
    "\27].-\27\\", -- OSC sequence
    "%s+", -- whitespace
  }

  for _, pattern in ipairs(patterns) do
    str = str:gsub(pattern, "")
  end

  return str ~= ""
end

function callbacks.create(term)
  vim.keymap.set("n", "q", function()
    term:close()
  end)
  vim.keymap.set("n", "<Esc>", function()
    term:close()
  end, { buffer = term.bufnr, nowait = true })
  vim.keymap.set({ "n", "t" }, "<C-/>", function()
    term:close()
  end, { buffer = term.bufnr, nowait = true })
end

function callbacks.on_stdout(term, _, data)
  if not term:is_open() then
    for _, line in ipairs(data) do
      if should_show_stdout(line) then
        term:open()
      end
    end
  end
end

function callbacks.on_stderr(term)
  if not term:is_open() then
    term:open()
  end
end

function callbacks.on_exit(term, _, exit_code)
  -- timer:stop()
  if exit_code ~= 0 then
    if not term:is_open() then
      vim.notify(term.display_name .. " exited with code " .. exit_code, vim.log.levels.ERROR)
      term:open()
    end
  else
    vim.notify(term.display_name .. " completed.", vim.log.levels.INFO)
    term:close()
  end
end

--- @param cmd string
--- @param display_name? string
--- @param opts? table
function M.background_command(cmd, display_name, opts)
  local defaults = {
    cmd = cmd,
    display_name = display_name or "Terminal",
    hidden = true,
    direction = "float",
    float_opts = {
      border = "curved",
      width = function()
        return math.floor(vim.o.columns * 0.95)
      end,
      height = function()
        return math.floor(vim.o.lines * 0.33)
      end,
      -- centered by default so exclude column
      row = function()
        return math.floor(vim.o.lines * 0.67) - 3
      end,
      title_pos = "center",
    },
  }
  opts = vim.tbl_deep_extend("keep", vim.tbl_extend("error", callbacks, opts or {}), defaults)
  local t = require("toggleterm.terminal").Terminal:new(opts)
  t:spawn()

  return t
end

return M
