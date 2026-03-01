local uv = vim.uv or vim.loop

local session_org_dir
local configured_org_dir
local capture_templates = {
  t = {
    description = "Task",
    template = "* TODO %?\n  %u",
  },
}
local agenda_custom_commands = {}
local agenda_builtin_commands = {
  a = "Agenda for current week or day",
  t = "List of all TODO entries",
  m = "Match a TAGS/PROP/TODO query",
  M = "Like m, but only for TODO entries",
  s = "Search for keywords",
}
local org_dir_history_file = vim.fn.stdpath("state") .. "/org_dir_history.json"
local org_dir_history_limit = 20
local setup_state = "idle"
local setup_queue = {}

---@param input string
---@return string
local function normalize_path(input)
  return vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(input), ":p"))
end

---@param data { title: string, prompt: string, items: table[] }
local function org_menu_handler(data)
  local options = {}
  for _, item in ipairs(data.items or {}) do
    if item.key and item.label then
      table.insert(options, item)
    end
  end

  vim.ui.select(options, {
    prompt = data.prompt,
    format_item = function(item)
      return ("[%s] %s"):format(item.key, item.label)
    end,
  }, function(choice)
    if choice and choice.action then
      choice.action()
    end
  end)
end

local function path_exists(path)
  local stat = uv.fs_stat(path)
  return stat and stat.type == "directory"
end

---@return string[]
local function load_org_dir_history()
  local stat = uv.fs_stat(org_dir_history_file)
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

---@param on_ready fun()
local function ensure_org_setup_async(on_ready)
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
        org_agenda_custom_commands = agenda_custom_commands,
        org_capture_templates = capture_templates,
        org_default_notes_file = session_org_dir .. "/inbox.org",
        mappings = {
          prefix = "<Leader>N",
          global = {
            org_agenda = "<Leader>Na/",
            org_capture = "<Leader>Nc/",
          },
        },
        ui = {
          input = {
            use_vim_ui = true,
          },
          menu = {
            handler = org_menu_handler,
          },
        },
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

local function exec_org(args)
  ensure_org_setup_async(function()
    vim.cmd({
      cmd = "Org",
      args = args,
    })
  end)
end

local function open_org_inbox()
  ensure_org_setup_async(function()
    vim.cmd.edit(session_org_dir .. "/inbox.org")
  end)
end

---@type LazyKeysSpec[]
local keys = {
  { "<leader>NI", open_org_inbox, desc = "Inbox" },
}

do
  local template_keys = vim.tbl_keys(capture_templates)
  table.sort(template_keys)
  for _, key in ipairs(template_keys) do
    local template_key = key
    local template = capture_templates[template_key] or {}
    local description = template.description or template_key
    table.insert(keys, {
      ("<leader>Nc%s"):format(template_key),
      function()
        exec_org({ "capture", template_key })
      end,
      desc = ("Capture: %s"):format(description),
    })
  end

  local agenda_keys = vim.tbl_keys(agenda_builtin_commands)
  if next(agenda_custom_commands) ~= nil then
    vim.list_extend(agenda_keys, vim.tbl_keys(agenda_custom_commands))
  end
  table.sort(agenda_keys)
  for _, key in ipairs(agenda_keys) do
    local agenda_key = key
    local description = agenda_builtin_commands[agenda_key]
    if not description and agenda_custom_commands[agenda_key] then
      description = agenda_custom_commands[agenda_key].description or agenda_key
    end
    table.insert(keys, {
      ("<leader>Na%s"):format(agenda_key),
      function()
        exec_org({ "agenda", agenda_key })
      end,
      desc = ("Agenda: %s"):format(description or agenda_key),
    })
  end
end

---@module 'lazy'
---@type LazyPluginSpec[]
return {
  {
    "nvim-orgmode/orgmode",
    ft = { "org" },
    cmd = { "Org" },
    keys = keys,
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter",
        opts = function(_, opts)
          opts.ensure_installed = opts.ensure_installed or {}
          if type(opts.ensure_installed) == "table" and not vim.tbl_contains(opts.ensure_installed, "org") then
            table.insert(opts.ensure_installed, "org")
          end
        end,
      },
    },
  },
}
