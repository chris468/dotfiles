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

---@alias chris468.luapad_type "luapad"|"neorepl"

---@type { [chris468.luapad_type]: snacks.win|nil }
local pads = {}

local new = {}

function new.luapad()
  ensure_project()
  local luapad_path = project_root / "Luapad"
  local win = Snacks.win({ style = "Luapad", file = luapad_path.filename })
  attach_luapad(win.buf)
  return win
end

function new.neorepl()
  local win = Snacks.win({ position = "right", enter = true })
  require("neorepl").new({
    on_init = function(bufnr)
      print("init")
      local bo = vim.bo[bufnr]
      bo.swapfile = false
      bo.bufhidden = "hide"
      bo.buftype = "nofile"
      bo.buflisted = false
      bo.modifiable = true
    end,
  })
  return win
end

---@param type chris468.luapad_type
function M.toggle(type)
  if pads[type] and pads[type]:win_valid() then
    pads[type]:toggle()
  else
    pads[type] = new[type]()
  end
end

return M
