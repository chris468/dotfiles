local Path = require("plenary.path")
local cmd = require("chris468.util.keymap").cmd
local save_restore_cursor_selection = require("chris468.util").save_restore_cursor_selection

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

---@alias chris468.luapad_type "luapad"|"snack"

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

function new.snack()
  ---@return string[]
  local function extract_output()
    local ns = vim.api.nvim_create_namespace("snacks_debug")
    local marks = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, { details = true })
    local lines = {}
    for _, mark in ipairs(marks) do
      for _, line in ipairs(mark[4].virt_lines) do
        for _, section in ipairs(line) do
          if section[2] == "SnacksDebugPrint" then
            table.insert(lines, section[1])
          end
        end
      end
    end

    return lines
  end

  ---@param lines string[]
  local function create_buffer(lines)
    vim.cmd([[ sp | enew ]])
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.bo.swapfile = false
    vim.bo.filetype = "text"
    vim.bo.bufhidden = "delete"
    vim.bo.buftype = "nofile"
    vim.bo.buflisted = false
    vim.bo.modifiable = true
    vim.wo.number = true
    vim.wo.relativenumber = true
    vim.wo.cursorline = true
    vim.keymap.set("n", "q", cmd("quit"), {
      buffer = true,
      desc = "Close",
      nowait = true,
    })
  end

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
      ["<localleader>c"] = {
        ---@diagnostic disable-next-line: assign-type-mismatch
        function()
          local lines = extract_output()
          if #lines == 0 then
            vim.notify("No output")
            return
          end
          create_buffer(lines)
        end,
        mode = "n",
        desc = "Open output in buffer",
      },
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
