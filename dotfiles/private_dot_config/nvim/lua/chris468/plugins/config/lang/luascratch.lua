---@module 'snacks'
local Path = require("plenary.path")
local run = require("chris468.util.lua").run

local M = {}

---@type snacks.layout?
local luascratch = nil

local actions = {}

local function append_to_output(...)
  if not (luascratch and luascratch:valid()) then
    return
  end

  local function _append(lines)
    luascratch.toggle(luascratch, "output", true)
    local buf = luascratch.wins.output.buf --[[ @as integer ]]

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

function actions.input()
  if not (luascratch and luascratch:valid()) then
    return
  end
  luascratch.wins.input:focus()
end

function actions.output()
  if not (luascratch and luascratch:valid()) then
    return
  end

  luascratch:toggle("output", true)
  luascratch.wins.output:focus()
end

function actions.hide_output()
  if not (luascratch and luascratch:valid()) then
    return
  end

  luascratch:toggle("output", false)
end

function actions.run()
  if not (luascratch and luascratch:valid() and luascratch.wins.input:valid()) then
    return
  end

  run(luascratch.wins.input.win, append_to_output)
end

function actions.run_current_line()
  if not (luascratch and luascratch:valid() and luascratch.wins.input:valid()) then
    return
  end

  run(luascratch.wins.input.win, append_to_output, true)
end

function actions.clear_output()
  if not (luascratch and luascratch:valid() and luascratch.wins.output:valid()) then
    return
  end

  local buf = luascratch.wins.output.buf --[[ @as integer ]]
  vim.bo[buf].modifiable = true
  local ok, err = pcall(vim.api.nvim_buf_set_lines, buf, 0, -1, false, {})
  vim.bo.modifiable = false
  if not ok then
    error(err)
  end
  vim.b[buf].chris468_luascratch_written = false
  luascratch:toggle("output", false)
end

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

local function create(opts)
  opts = vim.tbl_deep_extend("error", opts, {
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
        keys = {
          ["<C-J>"] = "output",
          ["<C-K>"] = "output",
          ["<localleader><localleader>"] = { "run", mode = { "n", "v" } },
          ["<localleader><cr>"] = "run_current_line",
          ["<localleader>c"] = { "clear_output", mode = { "n", "v" } },
        },
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
        keys = {
          ["<C-J>"] = "input",
          ["<C-K>"] = "input",
          ["<localleader><localleader>"] = { "run", mode = { "n", "v" } },
          ["<localleader><cr>"] = "run_current_line",
          ["<localleader>c"] = { "clear_output", mode = { "n", "v" } },
          q = "hide_output",
        },
        show = false,
      }),
    },
  })
  local layout = Snacks.layout.new(opts)
  prevent_focusing_root(layout)
  return layout
end

function M.toggle()
  if not luascratch then
    ensure_project()
    luascratch = create({
      on_close = function()
        luascratch = nil
      end,
    })
  else
    luascratch:close()
  end
end

return M
