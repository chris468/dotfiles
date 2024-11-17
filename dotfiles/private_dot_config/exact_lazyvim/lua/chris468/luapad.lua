local Path = require("plenary.path")

local M = {}

local project_root = Path:new(vim.fn.stdpath("state")) / "chris468" / "luapad"

local function ensure_project()
  local stylua = project_root / "stylua.toml"
  if not stylua:exists() then
    stylua:touch({ parents = true })
  end
end

--- @param buf integer
local function attach_luapad(buf)
  local evaluator = require("luapad.evaluator"):new({
    buf = buf,
  })
  evaluator:start()

  local last_changed_tick = vim.api.nvim_buf_get_changedtick(buf)

  vim.api.nvim_create_autocmd({ "InsertLeave", "CursorHoldI", "CursorHold" }, {
    buffer = buf,
    callback = function(_)
      local current_changed_tick = vim.api.nvim_buf_get_changedtick(buf)
      if current_changed_tick ~= last_changed_tick then
        evaluator:eval()
        last_changed_tick = current_changed_tick
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufUnload", {
    buffer = buf,
    callback = function()
      vim.schedule(function()
        evaluator:finish()
      end)
    end,
  })
  vim.api.nvim_create_autocmd("BufHidden", {
    buffer = buf,
    callback = function()
      evaluator:close_preview()
    end,
  })
end

---@type table<integer, snacks.win>
local pads = {}

Snacks.config.style("Luapad", {
  position = "right",
  bo = {
    swapfile = false,
    filetype = "lua",
    bufhidden = "hide",
    buftype = "nofile",
    buflisted = false,
    modifiable = true,
  },
  wo = {
    number = true,
    relativenumber = true,
    cursorline = true,
  },
  keys = {
    ["<leader><c-l>"] = Snacks.win.close,
    ["<c-/>"] = {
      "<c-/>",
      Snacks.win.close,
      mode = { "n", "i" },
    },
    ["<c-_>"] = {
      "<c-_>",
      Snacks.win.close,
      mode = { "n", "i" },
    },
  },
})

local function new()
  ensure_project()
  local luapad_path = project_root / "Luapad" .. (vim.v.count1 > 1 and " " .. vim.v.count1 or "")
  local win = Snacks.win({ style = "Luapad", file = luapad_path })
  attach_luapad(win.buf)
  return win
end

function M.toggle()
  if pads[vim.v.count1] and pads[vim.v.count1]:buf_valid() then
    pads[vim.v.count1]:toggle()
  else
    pads[vim.v.count1] = new()
  end
end

return M
