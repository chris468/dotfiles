local M = {}
local async = require("plenary.async")

local default_state_file = vim.fn.stdpath("state") .. "/path_selector_history.json"
local default_history_limit = 20

---@class util.path_selector.HistoryOptions
---@field history_key string
---@field history_limit? integer
---@field state_file? string

---@class util.path_selector.Options : util.path_selector.HistoryOptions
---@field select_prompt? string
---@field input_prompt? string
---@field new_item_label? string
---@field initial_path? string
---@field create_missing? boolean
---@field enable_path_picker? boolean
---@field allow_custom_path? boolean
---@field picker_prompt? string

local input = async.wrap(function(opts, callback)
  return vim.ui.input(opts, callback)
end, 2)

local select = async.wrap(function(items, opts, callback)
  return vim.ui.select(items, opts, callback)
end, 3)

---@param path string
---@return string
local function normalize_path(path)
  return vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(path), ":p"))
end

---@param path string
---@return boolean
local function path_exists(path)
  local stat = vim.uv.fs_stat(path)
  return stat ~= nil and stat.type == "directory"
end

---@param file string
---@return table<string, string[]>
local function load_history_map(file)
  local stat = vim.uv.fs_stat(file)
  if not stat or stat.type ~= "file" then
    return {}
  end

  local ok_read, lines = pcall(vim.fn.readfile, file)
  if not ok_read then
    return {}
  end

  local ok_decode, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok_decode or type(decoded) ~= "table" then
    return {}
  end

  local result = {}
  for key, entries in pairs(decoded) do
    if type(key) == "string" and type(entries) == "table" then
      local list = {}
      for _, item in ipairs(entries) do
        if type(item) == "string" and item ~= "" then
          table.insert(list, item)
        end
      end
      result[key] = list
    end
  end
  return result
end

---@param file string
---@param map table<string, string[]>
local function save_history_map(file, map)
  local parent = vim.fn.fnamemodify(file, ":h")
  vim.fn.mkdir(parent, "p")
  local ok, encoded = pcall(vim.json.encode, map)
  if not ok or type(encoded) ~= "string" then
    vim.notify("Failed to encode path selector history", vim.log.levels.WARN)
    return
  end
  local ok_write = pcall(vim.fn.writefile, { encoded }, file)
  if not ok_write then
    vim.notify(("Failed to write path selector history file: %s"):format(file), vim.log.levels.WARN)
  end
end

---@param history string[]
---@param path string
---@param limit integer
---@return string[]
local function record_history(history, path, limit)
  local deduped = { path }
  for _, item in ipairs(history) do
    if item ~= path then
      table.insert(deduped, item)
    end
    if #deduped >= limit then
      break
    end
  end
  return deduped
end

---@param dir string
---@return string
local function dirname_or_self(dir)
  local parent = vim.fs.dirname(dir)
  if not parent or parent == "" then
    return dir
  end
  return parent
end

local picker_pick_directory = async.wrap(function(start_dir, opts, callback)
  local completed = false

  local actions = {
    confirm = function(picker, item)
      if completed then
        return
      end
      completed = true
      picker:close()
      vim.schedule(function()
        if not item or type(item.file) ~= "string" or item.file == "" then
          callback(nil)
          return
        end
        callback(item.file)
      end)
    end,
    root_up = function(picker)
      local cwd = picker:cwd()
      if type(cwd) ~= "string" or cwd == "" then
        return
      end
      local parent = dirname_or_self(cwd)
      if parent == cwd then
        return
      end
      picker:set_cwd(parent)
      picker:find()
    end,
    root_selected = function(picker, item)
      local current = item or picker:current()
      local next_root = current and current.file or picker:cwd()
      if type(next_root) ~= "string" or next_root == "" then
        return
      end
      picker:set_cwd(next_root)
      picker:find()
    end,
  }

  local win_keys = {
    input = {
      keys = {
        ["<BS>"] = { "root_up", mode = { "n", "i" } },
        ["."] = { "root_selected", mode = { "n" } },
      },
    },
    list = {
      keys = {
        ["<BS>"] = "root_up",
        ["."] = "root_selected",
      },
    },
  }
  if opts.allow_custom_path then
    actions.custom_path = function(picker, item)
      if completed then
        return
      end
      local current = item or picker:current()
      local selected_dir = start_dir
      if current and type(current.file) == "string" and current.file ~= "" then
        selected_dir = current.file
      end

      completed = true
      picker:close()
      vim.schedule(function()
        vim.ui.input({ prompt = opts.input_prompt or "Path: ", default = selected_dir }, function(path)
          callback(path)
        end)
      end)
    end

    win_keys.input.keys["<C-y>"] = { "custom_path", mode = { "n", "i" } }
    win_keys.list.keys["<C-y>"] = "custom_path"
  end

  Snacks.picker.pick({
    source = "explorer",
    title = opts.picker_prompt or "Pick directory",
    cwd = start_dir,
    transform = function(item)
      if type(item) ~= "table" or type(item.file) ~= "string" or item.file == "" then
        return false
      end
      local stat = vim.uv.fs_stat(item.file)
      if not stat or stat.type ~= "directory" then
        return false
      end
      item.dir = true
      return item
    end,
    matcher = { fuzzy = false, sort_empty = false },
    hidden = true,
    ignored = true,
    follow = false,
    follow_file = false,
    show_empty = false,
    focus = "list",
    layout = {
      hidden = { "preview" },
      layout = {
        backdrop = false,
        width = 0.8,
        min_width = 80,
        height = 0.8,
        min_height = 20,
        box = "vertical",
        border = "rounded",
        title = "{title}",
        title_pos = "center",
        { win = "input", height = 1, border = "bottom" },
        { win = "list", border = "none" },
      },
    },
    actions = actions,
    win = win_keys,
    on_close = function()
      if completed then
        return
      end
      completed = true
      vim.schedule(function()
        callback(nil)
      end)
    end,
  })
end, 3)

---@param path string
---@param create_missing boolean
---@return string?
local function ensure_directory(path, create_missing)
  if path_exists(path) then
    return path
  end

  if not create_missing then
    vim.notify(("Path does not exist: %s"):format(path), vim.log.levels.ERROR)
    return nil
  end

  local choice = select({ "Create directory", "Cancel" }, {
    prompt = ("Path does not exist: %s"):format(path),
  })
  if choice ~= "Create directory" then
    return nil
  end

  local ok = vim.fn.mkdir(path, "p")
  if ok ~= 1 and not path_exists(path) then
    vim.notify(("Failed to create path: %s"):format(path), vim.log.levels.ERROR)
    return nil
  end

  return path
end

---@param opts table
---@param history string[]
---@return string?
local function prompt_new_path(opts, history)
  local fallback = opts.initial_path or history[1] or vim.fn.expand("~")
  if not opts.enable_path_picker then
    return input({ prompt = opts.input_prompt or "Path: ", default = fallback })
  end

  local start_dir = normalize_path(fallback)
  if not path_exists(start_dir) then
    start_dir = dirname_or_self(start_dir)
  end
  if not path_exists(start_dir) then
    start_dir = normalize_path(vim.fn.expand("~"))
  end

  return picker_pick_directory(start_dir, opts)
end

---@param opts table
---@param history string[]
---@return string?
local function prompt_path(opts, history)
  if #history == 0 then
    return prompt_new_path(opts, history)
  end

  local items = vim.tbl_map(function(path)
    return { kind = "history", value = path }
  end, history)
  table.insert(items, { kind = "new", value = "" })

  local choice = select(items, {
    prompt = opts.select_prompt or "Select path",
    format_item = function(item)
      if item.kind == "new" then
        return opts.new_item_label or "Enter new path..."
      end
      return item.value
    end,
  })
  if not choice then
    return nil
  end
  if choice.kind == "history" then
    return choice.value
  end
  return prompt_new_path(opts, history)
end

---@param opts util.path_selector.Options?
---@return string?
function M.select_path(opts)
  opts = opts or {}
  if type(opts.history_key) ~= "string" or opts.history_key == "" then
    vim.notify("path_selector.select_path requires opts.history_key", vim.log.levels.ERROR)
    return nil
  end

  local state_file = opts.state_file or default_state_file
  local history_limit = math.max(1, tonumber(opts.history_limit) or default_history_limit)
  local create_missing = opts.create_missing ~= false
  local allow_custom_path = opts.allow_custom_path ~= false
  opts.allow_custom_path = allow_custom_path

  local history_map = load_history_map(state_file)
  local history = history_map[opts.history_key] or {}

  local chosen = prompt_path(opts, history)
  if not chosen or chosen == "" then
    return nil
  end

  local normalized = normalize_path(chosen)
  local dir = ensure_directory(normalized, create_missing)
  if not dir then
    return nil
  end

  history_map[opts.history_key] = record_history(history, dir, history_limit)
  save_history_map(state_file, history_map)
  return dir
end

---@param dir string
---@param opts util.path_selector.HistoryOptions
function M.record_history(dir, opts)
  local state_file = opts.state_file or default_state_file
  local history_limit = math.max(1, tonumber(opts.history_limit) or default_history_limit)
  local history_map = load_history_map(state_file)
  local history = history_map[opts.history_key] or {}
  dir = normalize_path(dir)
  history_map[opts.history_key] = record_history(history, dir, history_limit)
  save_history_map(state_file, history_map)
end

return M
