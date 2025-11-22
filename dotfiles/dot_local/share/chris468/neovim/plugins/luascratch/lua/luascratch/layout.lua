---@module 'snacks'

local Path = require("plenary.path")
local config = require("luascratch.config")

--- @class chris468.luascratch.layout
local M = {
  ---@private
  ---@type snacks.layout?
  _layout = nil,
}

local project_root = Path:new(vim.fn.stdpath("state")) / "chris468" / "luapad"
local scratch = project_root / "Luascratch"
local output = project_root / "output"

local function ensure_project()
  local stylua = project_root / "stylua.toml"
  if not stylua:exists() then
    stylua:touch({ parents = true })
  end
end

local function prevent_focusing_root(layout)
  local root = layout.root

  local function is_focused()
    local current = vim.api.nvim_get_current_win()
    for _, win in pairs(layout.wins) do
      if win.win == current then
        return true
      end
    end
  end

  local left = true
  local last
  root:on("WinLeave", function()
    left = is_focused()
  end)
  root:on("WinEnter", function()
    if is_focused() then
      last = vim.api.nvim_get_current_win()
    end
  end)
  root:on("WinEnter", function()
    if left then
      vim.cmd.wincmd("h")
    elseif last and vim.api.nvim_win_is_valid(last) then
      vim.api.nvim_set_current_win(last)
    else
      vim.api.nvim_set_current_win(layout.wins.input.win)
    end
  end, { buf = true, nested = true })
end

---@private
function M:_create()
  local actions = require("luascratch.actions")
  self._layout = Snacks.layout.new({
    hidden = { "output" },
    layout = {
      backdrop = false,
      border = "none",
      box = "vertical",
      height = 0,
      min_width = 20,
      position = "right",
      width = 0.4,
      {
        border = "top",
        enter = true,
        height = 0.75,
        title = "Lua scratch",
        title_pos = "center",
        win = "input",
      },
      {
        border = "top",
        title = "Output",
        title_pos = "center",
        win = "output",
      },
    },
    on_close = function()
      self._layout = nil
    end,
    wins = {
      input = Snacks.win.new({
        actions = actions,
        bo = {
          ft = "lua",
          buftype = "nofile",
          buflisted = false,
          modifiable = true,
        },
        enter = false,
        file = scratch.filename,
        on_close = M.toggle,
        keys = config.opts.mappings.input,
        show = false,
      }),
      output = Snacks.win.new({
        actions = actions,
        bo = {
          ft = "text",
          buftype = "nofile",
          buflisted = false,
          modifiable = false,
        },
        enter = false,
        file = output.filename,
        keys = config.opts.mappings.output,
        show = false,
      }),
    },
  })
  prevent_focusing_root(self._layout)
end

function M:valid()
  return self._layout and self._layout:valid()
end

function M:input_valid()
  return self:valid() and self._layout.wins.input:valid()
end

function M:output_valid()
  return self:valid() and self._layout.wins.output:valid()
end

function M:focus_input()
  self._layout.wins.input:focus()
end

function M:focus_output()
  self._layout.wins.output:focus()
end

---@param enable? boolean
function M:toggle_output(enable)
  self._layout:toggle("output", enable)
end

function M:input_win()
  return self._layout.wins.input.win
end

---@return integer
function M:output_buf()
  return self._layout.wins.output.buf
end

function M:toggle()
  if not self._layout then
    ensure_project()
    self:_create()
  else
    self._layout:close()
  end
end

return M
