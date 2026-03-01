local M = {}
local menu = require("util.ui.menu")
local async = require("plenary.async")

local session_org_dir
local configured_org_dir
local org_dir_history_file = vim.fn.stdpath("state") .. "/org_dir_history.json"
local org_dir_history_limit = 20
local in_flight

local input = async.wrap(function(opts, callback)
  return vim.ui.input(opts, callback)
end, 2)
local select = async.wrap(function(items, opts, callback)
  return vim.ui.select(items, opts, callback)
end, 3)

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

  local choice = select({ "Create directory", "Cancel" }, {
    prompt = ("Org notes path does not exist: %s"):format(dir),
  })
  if choice ~= "Create directory" then
    return false
  end

  local ok = vim.fn.mkdir(dir, "p")
  if ok ~= 1 and not path_exists(dir) then
    vim.notify(("Failed to create Org notes path: %s"):format(dir), vim.log.levels.ERROR)
    return false
  end

  return true
end

---@param input string?
---@return string?
local function prepare_org_dir(input)
  if input == nil or input == "" then
    vim.notify("Org notes path is required", vim.log.levels.ERROR)
    return nil
  end

  local dir = normalize_path(input)
  if not ensure_dir_exists(dir) then
    return nil
  end

  record_org_dir_history(dir)
  return dir
end

---@param initial string
---@return string?
local function prompt_new_org_dir(initial)
  local input = input({ prompt = "Org notes path: ", default = initial })
  return prepare_org_dir(input)
end

---@return string?
local function prompt_org_dir()
  local history = load_org_dir_history()
  if #history == 0 then
    return prompt_new_org_dir(vim.fn.expand("~"))
  end

  local items = vim.tbl_map(function(dir)
    return { kind = "history", value = dir }
  end, history)
  table.insert(items, { kind = "new", value = "" })

  local choice = select(items, {
    prompt = "Select Org notes path",
    format_item = function(item)
      if item.kind == "new" then
        return "Enter new path..."
      end
      return item.value
    end,
  })
  if not choice then
    return nil
  end
  if choice.kind == "history" then
    return prepare_org_dir(choice.value)
  end
  return prompt_new_org_dir(history[1])
end

---@return boolean
local function configure_org_path()
  local dir = prompt_org_dir()
  if not dir then
    return false
  end

  session_org_dir = dir
  if configured_org_dir == session_org_dir then
    return true
  end

  local ok, err = pcall(require("orgmode").setup, {
    org_agenda_files = { session_org_dir .. "/**/*.org" },
    org_default_notes_file = session_org_dir .. "/inbox.org",
  })
  if not ok then
    vim.notify(("Failed to configure orgmode: %s"):format(err), vim.log.levels.ERROR)
    return false
  end

  configured_org_dir = session_org_dir
  return true
end

function M.select_org_path()
  if in_flight ~= nil then
    return
  end

  in_flight = true

  async.run(function()
    local ok, result = pcall(configure_org_path)
    return ok, result
  end, function(stat, ok, result)
    in_flight = nil
    if not stat then
      vim.notify(("Org action failed: %s"):format(ok), vim.log.levels.ERROR)
      return
    end
    if not ok then
      vim.notify(("Org action failed: %s"):format(result), vim.log.levels.ERROR)
    end
  end)
end

---@param data { title?: string, prompt?: string, items?: table[] }
function M.org_menu_handler(data)
  local title = data.title or "Org menu"
  local prompt = data.prompt
  if prompt and prompt == title then
    prompt = nil
  end
  menu.open({
    title = title,
    prompt = prompt,
    items = data.items or {},
    on_error = function(err)
      vim.notify(("Org action failed: %s"):format(err), vim.log.levels.ERROR)
    end,
  })
end

return M
