---@module 'snacks'
local Path = require("plenary.path")

local M = {}

---@type snacks.layout?
local luascratch = nil

local project_root = Path:new(vim.fn.stdpath("state")) / "chris468" / "luapad"
local scratch = project_root / "Luascratch"
local output = project_root / "output"

local function ensure_project()
  local stylua = project_root / "stylua.toml"
  if not stylua:exists() then
    stylua:touch({ parents = true })
  end
end

local function create(opts)
  opts = vim.tbl_deep_extend("error", opts, {
    -- TODO: iniitally hide, show on first output
    -- hidden = { "output" },
    layout = {
      backdrop = false,
      width = 0.4,
      min_width = 20,
      height = 0,
      position = "right",
      border = "none",
      box = "vertical",
      {
        win = "input",
        height = 0.75,
        border = "top",
        title = "Lua scratch",
        title_pos = "center",
      },
      {
        win = "output",
        border = "top",
        title = "Output",
        title_pos = "center",
      },
    },
    wins = {
      input = Snacks.win.new({
        show = false,
        enter = false,
        file = scratch.filename,
        bo = {
          ft = "lua",
          buftype = "nofile",
          buflisted = false,
        },
      }),
      output = Snacks.win.new({
        show = false,
        enter = false,
        file = output.filename,
        bo = {
          ft = "text",
          buftype = "nofile",
          buflisted = false,
        },
      }),
    },
  })
  return Snacks.layout.new(opts)
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
