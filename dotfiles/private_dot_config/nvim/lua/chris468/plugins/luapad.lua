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

  return buf
end

local function luapad_split()
  local luapad_path, error = create_project()
  if not luapad_path then
    vim.notify(error or "unknown error", vim.log.levels.ERROR)
    return
  end

  create_buffer(luapad_path)
end
return {
  "rafcamlet/nvim-luapad",
  cmd = {
    "Luapad",
    "LuaRun",
    "Lua",
  },
  keys = {
    { "<leader>tL", "<cmd>Luapad<CR>", desc = "Lua REPL (builtin)" },
    { "<leader>tl", luapad_split, desc = "Lua REPL" },
  },
}
