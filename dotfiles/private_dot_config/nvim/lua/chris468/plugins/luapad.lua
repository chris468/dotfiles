--- @param summary string
--- @param err_name string|nil
--- @param err_message string|nil
--- @return string error
local function build_error(summary, err_name, err_message)
  local err = {}
  if err_name then
    err[#err + 1] = err_name
  end

  if err_message then
    err[#err + 1] = err_message
  end

  return summary .. (#err > 0 and (" (" .. table.concat(err, ": ") .. ")") or "")
end

--- @return string|nil path, string|nil error
local function create_project()
  local tmpdir, err_name, err_message = vim.loop.fs_mkdtemp("/tmp/luapad.XXXX")
  if not tmpdir then
    return nil, build_error("failed to create tempdir for luapad", err_name, err_message)
  end

  local stylua_path = table.concat({ tmpdir, "stylua.toml" }, "/")
  local stylua_fd
  stylua_fd, err_name, err_message = vim.loop.fs_open(stylua_path, "w", 384) -- 0600
  if not stylua_fd then
    return nil, build_error("Failed to create " .. stylua_path, err_name, err_message)
  end
  vim.loop.fs_close(stylua_fd)

  return table.concat({ tmpdir, "LuaPad" }, "/")
end

--- @param path string
--- @return integer buffer
local function create_buffer(path)
  vim.api.nvim_command("botright vsplit " .. path)
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "lua"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"

  return buf
end

--- @param buffer integer
local function attach_luapad(buffer)
  local evaluator = require("luapad.evaluator"):new({
    buf = buffer,
  })
  evaluator:start()

  local last_changed_tick = vim.api.nvim_buf_get_changedtick(buffer)

  vim.api.nvim_create_autocmd({ "InsertLeave", "CursorHoldI", "CursorHold" }, {
    buffer = buffer,
    callback = function(_)
      local current_changed_tick = vim.api.nvim_buf_get_changedtick(buffer)
      if current_changed_tick ~= last_changed_tick then
        evaluator:eval()
        last_changed_tick = current_changed_tick
      end
    end,
  })
end

local function luapad_split()
  local luapad_path, error = create_project()
  if not luapad_path then
    vim.notify(error or "unknown error", vim.log.levels.ERROR)
    return
  end

  local buffer = create_buffer(luapad_path)

  attach_luapad(buffer)
end

return {
  "rafcamlet/nvim-luapad",
  cmd = {
    "Luapad",
    "LuaRun",
    "Lua",
  },
  config = function(_, opts)
    require("luapad").setup(opts)
    vim.api.nvim_create_user_command("Luapad", luapad_split, { force = true })
  end,
  keys = {
    { "<leader>ml", luapad_split, desc = "Lua REPL" },
  },
  opts = {
    eval_on_change = false,
    eval_on_move = false,
  },
  version = false,
}
