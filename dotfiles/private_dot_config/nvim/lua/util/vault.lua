local M = {}

local uv = vim.uv or vim.loop
local state_file = vim.fs.joinpath(vim.fn.stdpath("state"), "chris468-vault-state.json")
local default_state = {
  current = nil,
  mru = {},
}
local max_mru = 10

---@return { current: string|nil, mru: string[] }
local function load_state()
  if vim.fn.filereadable(state_file) ~= 1 then
    return vim.deepcopy(default_state)
  end

  local ok_read, lines = pcall(vim.fn.readfile, state_file)
  if not ok_read then
    return vim.deepcopy(default_state)
  end

  local ok_decode, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok_decode or type(decoded) ~= "table" then
    return vim.deepcopy(default_state)
  end

  local state = {
    current = type(decoded.current) == "string" and decoded.current or nil,
    mru = {},
  }
  if type(decoded.mru) == "table" then
    for _, item in ipairs(decoded.mru) do
      if type(item) == "string" then
        table.insert(state.mru, item)
      end
    end
  end

  return state
end

---@param state { current: string|nil, mru: string[] }
local function save_state(state)
  local dir = vim.fs.dirname(state_file)
  if dir and dir ~= "" then
    vim.fn.mkdir(dir, "p")
  end
  local ok_encode, encoded = pcall(vim.json.encode, state)
  if not ok_encode then
    return
  end
  vim.fn.writefile({ encoded }, state_file)
end

---@param path string
---@return string
local function normalize(path)
  return vim.fs.normalize(path)
end

---@param path string
---@return boolean
local function dir_exists(path)
  local stat = uv.fs_stat(path)
  return stat ~= nil and stat.type == "directory"
end

---@param path string
---@return boolean
function M.is_vault_path(path)
  if type(path) ~= "string" or path == "" then
    return false
  end
  local normalized = normalize(path)
  return dir_exists(normalized) and dir_exists(vim.fs.joinpath(normalized, ".obsidian"))
end

---@param path string
---@return string|nil
function M.find_vault_for_path(path)
  if type(path) ~= "string" or path == "" then
    return nil
  end

  local start = normalize(path)
  local stat = uv.fs_stat(start)
  if stat and stat.type ~= "directory" then
    start = vim.fs.dirname(start)
  end

  if not start or start == "" then
    return nil
  end

  local probe = start
  while probe do
    if dir_exists(vim.fs.joinpath(probe, ".obsidian")) then
      return probe
    end
    local parent = vim.fs.dirname(probe)
    if parent == probe then
      break
    end
    probe = parent
  end

  return nil
end

---@param mru string[]
---@param path string
---@return string[]
local function update_mru(mru, path)
  local normalized = normalize(path)
  local next = {}
  local seen = {}

  if dir_exists(normalized) then
    table.insert(next, normalized)
    seen[normalized] = true
  end

  for _, item in ipairs(mru) do
    local candidate = normalize(item)
    if not seen[candidate] and dir_exists(candidate) then
      table.insert(next, candidate)
      seen[candidate] = true
    end
    if #next >= max_mru then
      break
    end
  end

  return next
end

---@param path string
---@return string
function M.set_current(path)
  local normalized = normalize(path)
  local state = load_state()
  state.current = normalized
  state.mru = update_mru(state.mru, normalized)
  save_state(state)
  return normalized
end

---@return string|nil
function M.get_current()
  local state = load_state()
  if type(state.current) == "string" and state.current ~= "" and dir_exists(state.current) then
    return state.current
  end
  return nil
end

---@return string[]
function M.get_mru()
  local state = load_state()
  local next = {}
  for _, item in ipairs(state.mru) do
    if dir_exists(item) then
      table.insert(next, item)
    end
  end
  return next
end

---@param path string
---@param context string
---@return string|nil
local function validate_vault_path(path, context)
  local normalized = normalize(path)
  if not dir_exists(normalized) then
    vim.notify(("Invalid vault path for %s: directory does not exist"):format(context), vim.log.levels.ERROR)
    return nil
  end
  if not dir_exists(vim.fs.joinpath(normalized, ".obsidian")) then
    vim.notify(("Invalid vault path for %s: missing .obsidian directory"):format(context), vim.log.levels.ERROR)
    return nil
  end
  return normalized
end

---@param context string
---@param callback fun(path: string|nil)
local function prompt_for_vault(context, callback)
  local mru = M.get_mru()
  local choices = vim.deepcopy(mru)
  local enter_new = "Enter new vault path..."
  table.insert(choices, enter_new)

  vim.ui.select(choices, {
    prompt = ("Select vault for %s"):format(context),
    format_item = function(item)
      return item
    end,
  }, function(choice)
    if not choice then
      vim.notify(("Canceled vault selection for %s"):format(context), vim.log.levels.WARN)
      callback(nil)
      return
    end

    if choice == enter_new then
      vim.ui.input({
        prompt = ("Vault path for %s: "):format(context),
        default = M.get_current() or vim.fn.getcwd(),
      }, function(value)
        if not value or value == "" then
          vim.notify(("Canceled vault selection for %s"):format(context), vim.log.levels.WARN)
          callback(nil)
          return
        end
        callback(validate_vault_path(value, context))
      end)
      return
    end

    callback(validate_vault_path(choice, context))
  end)
end

---@param opts? { context?: string, path?: string, allow_prompt?: boolean, force_prompt?: boolean }
---@param callback fun(path: string|nil)
function M.resolve_async(opts, callback)
  opts = opts or {}
  local context = opts.context or "notes/tasks"
  local allow_prompt = opts.allow_prompt ~= false
  local force_prompt = opts.force_prompt == true

  if force_prompt and allow_prompt then
    prompt_for_vault(context, function(chosen)
      callback(chosen and M.set_current(chosen) or nil)
    end)
    return
  end

  local discovered = M.find_vault_for_path(opts.path or vim.api.nvim_buf_get_name(0))
  if discovered then
    callback(M.set_current(discovered))
    return
  end

  local current = M.get_current()
  if current and M.is_vault_path(current) then
    callback(M.set_current(current))
    return
  end

  if not allow_prompt then
    callback(nil)
    return
  end

  prompt_for_vault(context, function(chosen)
    callback(chosen and M.set_current(chosen) or nil)
  end)
end

---@param opts? { context?: string, path?: string, allow_prompt?: boolean }
---@return string|nil
function M.resolve(opts)
  opts = opts or {}
  local discovered = M.find_vault_for_path(opts.path or vim.api.nvim_buf_get_name(0))
  if discovered then
    return M.set_current(discovered)
  end

  local current = M.get_current()
  if current and M.is_vault_path(current) then
    return M.set_current(current)
  end

  return nil
end

return M
