---@module 'snacks'

local M = {}

---@type snacks.layout?
local luascratch = nil

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
        bo = {
          ft = "lua",
          buftype = "nofile",
          buflisted = false,
        },
      }),
      output = Snacks.win.new({
        show = false,
        enter = false,
        bo = {
          ft = "text",
          buftype = "nofile",
          buflisted = false,
        },
      }),
    },
  })
  vim.print(vim.inspect({ opts = opts }))
  return Snacks.layout.new(opts)
end

function M.toggle()
  if not luascratch then
    luascratch = create({
      on_close = function()
        luascratch = nil
      end,
    })
    vim.print(vim.inspect({ luascratch }))
  else
    luascratch:close()
  end
end

return M
