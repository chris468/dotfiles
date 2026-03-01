local M = {}
local menu = require("util.ui.menu")

local session_org_dir
local configured_org_dir
local org_dir_history_file = vim.fn.stdpath("state") .. "/org_dir_history.json"
local org_dir_history_limit = 20
local setup_state = "idle"
local setup_queue = {}

---@param input string
---@return string
local function normalize_path(input)
  return vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(input), ":p"))
end

---@param path string
---@return boolean
local function path_exists(path)
  local stat = vim.uv.fs_stat(path)
  return stat ~= nil and stat.type == "directory"
end

---@return string[]
local function load_org_dir_history()
  local stat = vim.uv.fs_stat(org_dir_history_file)
  if not stat or stat.type ~= "file" then
    return {}
  end

  local ok_read, lines = pcall(vim.fn.readfile, org_dir_history_file)
  if not ok_read then
    return {}
  end
  local raw = table.concat(lines, "\n")

  local ok_decode, decoded = pcall(vim.json.decode, raw)
  if not ok_decode or type(decoded) ~= "table" then
    return {}
  end

  local history = {}
  for _, item in ipairs(decoded) do
    if type(item) == "string" and item ~= "" then
      table.insert(history, item)
    end
  end
  return history
end

---@param history string[]
local function save_org_dir_history(history)
  local parent = vim.fn.fnamemodify(org_dir_history_file, ":h")
  vim.fn.mkdir(parent, "p")
  local ok, encoded = pcall(vim.json.encode, history)
  if not ok or type(encoded) ~= "string" then
    return
  end
  pcall(vim.fn.writefile, { encoded }, org_dir_history_file)
end

---@param dir string
local function record_org_dir_history(dir)
  local history = load_org_dir_history()
  local deduped = { dir }
  for _, item in ipairs(history) do
    if item ~= dir then
      table.insert(deduped, item)
    end
    if #deduped >= org_dir_history_limit then
      break
    end
  end
  save_org_dir_history(deduped)
end

---@param dir string
---@return boolean
local function ensure_dir_exists(dir)
  if path_exists(dir) then
    return true
  end

  local choice = vim.fn.confirm(("Org notes path does not exist:\n%s\n\nCreate it?"):format(dir), "&Yes\n&No", 1)
  if choice ~= 1 then
    return false
  end

  local ok = vim.fn.mkdir(dir, "p")
  if ok ~= 1 and not path_exists(dir) then
    vim.notify(("Failed to create Org notes path: %s"):format(dir), vim.log.levels.ERROR)
    return false
  end

  return true
end

---@param input string
---@param on_done fun(dir: string?)
local function resolve_org_dir_input_async(input, on_done)
  if input == nil or input == "" then
    vim.notify("Org notes path is required", vim.log.levels.ERROR)
    on_done(nil)
    return
  end

  local dir = normalize_path(input)
  if not ensure_dir_exists(dir) then
    on_done(nil)
    return
  end

  record_org_dir_history(dir)
  on_done(dir)
end

---@param initial string
---@param on_done fun(dir: string?)
local function prompt_new_org_dir_async(initial, on_done)
  vim.ui.input({ prompt = "Org notes path: ", default = initial }, function(input)
    resolve_org_dir_input_async(input, on_done)
  end)
end

---@param on_done fun(dir: string?)
local function prompt_org_dir_async(on_done)
  local history = load_org_dir_history()
  if #history == 0 then
    prompt_new_org_dir_async(vim.fn.expand("~"), on_done)
    return
  end

  local items = vim.tbl_map(function(dir)
    return { kind = "history", value = dir }
  end, history)
  table.insert(items, { kind = "new", value = "" })

  vim.ui.select(items, {
    prompt = "Select Org notes path",
    format_item = function(item)
      if item.kind == "new" then
        return "Enter new path..."
      end
      return item.value
    end,
  }, function(choice)
    if not choice then
      on_done(nil)
      return
    end
    if choice.kind == "history" then
      resolve_org_dir_input_async(choice.value, on_done)
      return
    end
    prompt_new_org_dir_async(history[1], on_done)
  end)
end

---@param on_ready? fun()
function M.select_org_path(on_ready)
  on_ready = on_ready or function() end
  if setup_state == "ready" then
    on_ready()
    return
  end

  table.insert(setup_queue, on_ready)
  if setup_state == "prompting" then
    return
  end

  setup_state = "prompting"
  prompt_org_dir_async(function(dir)
    if not dir then
      setup_state = "idle"
      setup_queue = {}
      return
    end

    session_org_dir = dir
    if configured_org_dir ~= session_org_dir then
      local ok, err = pcall(require("orgmode").setup, {
        org_agenda_files = { session_org_dir .. "/**/*.org" },
        org_default_notes_file = session_org_dir .. "/inbox.org",
      })
      if not ok then
        vim.notify(("Failed to configure orgmode: %s"):format(err), vim.log.levels.ERROR)
        setup_state = "idle"
        setup_queue = {}
        return
      end
      configured_org_dir = session_org_dir
    end

    setup_state = "ready"
    local queued = setup_queue
    setup_queue = {}
    for _, callback in ipairs(queued) do
      local ok, err = pcall(callback)
      if not ok then
        vim.notify(("Org action failed: %s"):format(err), vim.log.levels.ERROR)
      end
    end
  end)
end

---@param data { title: string, prompt: string, items: table[] }
function M.org_menu_handler(data)
  menu.open({
    title = data.title or "Org menu",
    prompt = data.prompt or "Select action",
    items = data.items or {},
    on_error = function(err)
      vim.notify(("Org action failed: %s"):format(err), vim.log.levels.ERROR)
    end,
  })
end

return M
