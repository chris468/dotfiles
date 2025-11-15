---@module 'snacks'
local Path = require("plenary.path")

local M = {}

---@type snacks.layout?
local luascratch = nil

local actions = {}

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
      width = 0.4,
      min_width = 20,
      height = 0,
      position = "right",
      border = "none",
      box = "vertical",
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
        },
        show = false,
      }),
      output = Snacks.win.new({
        actions = actions,
        bo = {
          ft = "text",
          buftype = "nofile",
          buflisted = false,
        },
        enter = false,
        file = output.filename,
        keys = {
          ["<C-J>"] = "input",
          ["<C-K>"] = "input",
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
