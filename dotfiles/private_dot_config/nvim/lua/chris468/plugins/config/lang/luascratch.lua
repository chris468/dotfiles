---@module 'snacks'

local M = {}

---@type snacks.layout.Box
local layout = {
  backdrop = false,
  width = 0.4,
  min_width = 20,
  height = 0,
  position = "right",
  border = "left",
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
}

---@type snacks.layout?
local luascratch = nil

local function create(opts)
  return Snacks.layout.new(vim.tbl_deep_extend("error", opts, {
    -- TODO: iniitally hide, show on first output
    -- hidden = { "output" },
    layout = vim.deepcopy(layout),
    wins = {
      input = Snacks.win.new({}),
      output = Snacks.win.new({}),
    },
  }))
end

function M.toggle()
  if not luascratch then
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
