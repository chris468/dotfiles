local Path = require("plenary.path")

local M = {}

local project_root = Path:new(vim.fn.stdpath("state")) / "chris468" / "luapad"

local function ensure_project()
  local stylua = project_root / "stylua.toml"
  if not stylua:exists() then
    stylua:touch({ parents = true })
  end
end

---@type integer|nil
local buffer

--- @param path string
--- @return integer buffer
local function create_buffer(path)
  vim.api.nvim_command("botright vsplit " .. path)
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "lua"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].buflisted = false

  return buf
end

--- @param buf integer
local function attach_luapad(buf)
  local evaluator = require("luapad.evaluator"):new({
    buf = buf,
  })
  evaluator:start()

  local last_changed_tick = vim.api.nvim_buf_get_changedtick(buf)

  vim.api.nvim_create_autocmd({ "InsertLeave", "CursorHoldI", "CursorHold" }, {
    buffer = buffer,
    callback = function(_)
      local current_changed_tick = vim.api.nvim_buf_get_changedtick(buf)
      if current_changed_tick ~= last_changed_tick then
        evaluator:eval()
        last_changed_tick = current_changed_tick
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufUnload", {
    buffer = buffer,
    callback = function(arg)
      vim.schedule(function()
        evaluator:finish()
      end)
    end,
  })
  vim.api.nvim_create_autocmd("BufHidden", {
    buffer = buffer,
    callback = function()
      evaluator:close_preview()
    end,
  })
end

function M.toggle()
  if buffer and vim.api.nvim_buf_is_loaded(buffer) then
    local win = vim.fn.win_findbuf(buffer)
    if win and win[1] then
      vim.api.nvim_win_hide(win[1])
    else
      vim.api.nvim_command("botright vsplit")
      vim.api.nvim_win_set_buf(0, buffer)
    end
    return
  end

  ensure_project()
  local luapad_path = project_root / "Luapad" .. (vim.v.count1 > 1 and " " .. vim.v.count1 or "")
  buffer = create_buffer(luapad_path)
  attach_luapad(buffer)
end

return M
