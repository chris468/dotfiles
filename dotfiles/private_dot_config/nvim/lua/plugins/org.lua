local uv = vim.uv or vim.loop

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

---@param data { title: string, prompt: string, items: table[] }
local function org_menu_handler(data)
  local ok_snacks_win, snacks_win = pcall(require, "snacks.win")
  if not ok_snacks_win then
    vim.notify("Org menu requires snacks.win, but it could not be loaded", vim.log.levels.ERROR)
    return
  end

  local options = {}
  local seen_keys = {}
  local duplicate_keys = {}
  for _, item in ipairs(data.items or {}) do
    if item.key and item.label then
      if seen_keys[item.key] then
        duplicate_keys[item.key] = true
      else
        seen_keys[item.key] = true
      end
      table.insert(options, item)
    end
  end

  if #options == 0 then
    vim.notify("Org menu has no selectable items", vim.log.levels.WARN)
    return
  end

  local duplicate_list = vim.tbl_keys(duplicate_keys)
  if #duplicate_list > 0 then
    table.sort(duplicate_list)
    vim.notify(
      ("Org menu has duplicate shortcut keys: %s"):format(table.concat(duplicate_list, ", ")),
      vim.log.levels.WARN
    )
  end

  local title = type(data.title) == "string" and data.title ~= "" and data.title or "Org menu"
  local prompt = type(data.prompt) == "string" and data.prompt ~= "" and data.prompt or "Select action"
  local lines = {
    prompt,
    "",
  }
  local first_option_row = #lines + 1
  for _, item in ipairs(options) do
    table.insert(lines, ("[%s] %s"):format(item.key, item.label))
  end
  table.insert(lines, "")
  table.insert(lines, "Esc cancel")

  local max_line_width = 0
  for _, line in ipairs(lines) do
    max_line_width = math.max(max_line_width, vim.api.nvim_strwidth(line))
  end

  local max_width = math.max(32, math.min(max_line_width + 2, vim.o.columns - 6))
  local max_height = math.max(6, math.min(#lines, vim.o.lines - 6))

  local menu_done = false
  ---@type snacks.win?
  local menu_win = nil
  local function close_menu()
    if menu_win and menu_win:valid() then
      menu_win:close()
    end
  end

  ---@param action? fun()
  local function finish_menu(action)
    if menu_done then
      return
    end
    menu_done = true
    close_menu()
    if action then
      local ok, err = pcall(action)
      if not ok then
        vim.notify(("Org action failed: %s"):format(err), vim.log.levels.ERROR)
      end
    end
  end

  local keys = {
    ["<Esc>"] = {
      "<Esc>",
      function()
        finish_menu()
      end,
      mode = "n",
      nowait = true,
      desc = "Cancel",
    },
  }

  for _, item in ipairs(options) do
    if not keys[item.key] then
      keys[item.key] = {
        item.key,
        function()
          finish_menu(item.action)
        end,
        mode = "n",
        nowait = true,
        desc = item.label,
      }
    end
  end

  menu_win = snacks_win({
    border = "rounded",
    bo = {
      bufhidden = "wipe",
      buftype = "nofile",
      modifiable = false,
      readonly = true,
      swapfile = false,
      filetype = "org",
    },
    enter = true,
    focusable = true,
    footer_keys = { "<Esc>" },
    height = max_height,
    keys = keys,
    position = "float",
    relative = "editor",
    text = lines,
    title = title,
    title_pos = "center",
    width = max_width,
    wo = {
      cursorline = true,
      foldenable = false,
      number = false,
      relativenumber = false,
      signcolumn = "no",
      spell = false,
      statuscolumn = "",
      wrap = false,
    },
    on_win = function(win)
      if first_option_row <= vim.api.nvim_buf_line_count(win.buf) then
        pcall(vim.api.nvim_win_set_cursor, win.win, { first_option_row, 0 })
      end
    end,
  })
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

---@param on_ready? fun()
local function select_org_path(on_ready)
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

---@module 'lazy'
---@type LazyPluginSpec[]
return {
  {
    "nvim-orgmode/orgmode",
    ft = { "org" },
    cmd = { "Org" },
    keys = {
      { "<Leader>NO", select_org_path, desc = "Select path" },
    },
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
    opts = {
      mappings = {
        prefix = "<Leader>N",
      },
      ui = {
        input = {
          use_vim_ui = true,
        },
        menu = {
          handler = org_menu_handler,
        },
      },
    },
  },
}
