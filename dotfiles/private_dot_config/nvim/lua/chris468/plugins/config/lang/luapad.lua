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

---@alias chris468.luapad_type "luapad"|"neorepl"|"lua-console"|"snack"

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

new["lua-console"] = function()
  local luapad_path = project_root / "lua-console"
  local win = Snacks.win({ style = "Luapad", file = luapad_path.filename })
  require("lua-console.utils").attach_toggle(win.buf)
  return win
end

---@param fn fun():any
local function save_restore_cursor_selection(fn)
  local buffer = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  local marks = { "<", ">" }
  local saved = {}
  saved.marks = vim.tbl_map(function(v)
    return { v, vim.api.nvim_buf_get_mark(buffer, v) }
  end, marks)
  saved.cursor = vim.api.nvim_win_get_cursor(win)

  local ok, ret = pcall(fn)

  vim.api.nvim_win_set_cursor(win, saved.cursor)
  for _, mark in ipairs(saved.marks) do
    vim.api.nvim_buf_set_mark(buffer, mark[1], mark[2][1], mark[2][2], {})
  end

  if not ok then
    error(ret)
  end

  return ret
end

function new.snack()
  local luapad_path = project_root / "lua-console"
  return Snacks.win({
    style = "Luapad",
    file = luapad_path.filename,
    keys = {
      ---@diagnostic disable-next-line: assign-type-mismatch
      ["<localleader><localleader>"] = { Snacks.debug.run, mode = { "n", "v" }, desc = "Run" },
      ["<localleader><CR>"] = {
        ---@diagnostic disable-next-line: assign-type-mismatch
        function()
          save_restore_cursor_selection(function()
            vim.api.nvim_buf_call(0, function()
              vim.cmd([[normal! V]])
              Snacks.debug.run()
            end)
          end)
        end,
        mode = "n",
        desc = "Run current line",
      },
      -- TODO: mapping to dump to buffer
      --[[

      { 0, 13, 8, 0 }
      { 0, 13, 8, 0 }
      { "s" }
      s
      167
      {}

      local marks = vim.api.nvim_buf_get_extmarks(3, 167, 0, -1, {details=true})

      for _, mark in ipairs(marks) do
        print(mark[4].virt_lines)
      end


      for _, mark in ipairs(marks) do
        for _, line in ipairs(mark[4].virt_lines) do
          for _, section in ipairs(line) do
            if section[2] == "SnacksDebugPrint" then
              print(section[1])
            end
          end
        end
      end

      --]]
    },
  })
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
