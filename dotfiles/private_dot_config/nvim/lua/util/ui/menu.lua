local M = {}

---@param opts { title?: string, prompt?: string, items?: table[], filetype?: string, on_error?: fun(err: string) }
function M.open(opts)
  local options = {}
  local seen_keys = {}
  for _, item in ipairs(opts.items or {}) do
    if item.label then
      if item.key and not seen_keys[item.key] then
        table.insert(options, item)
        seen_keys[item.key] = item
      else
        table.insert(options, { label = item.label })
      end
    end
  end

  if #options == 0 then
    vim.notify("Menu has no selectable items", vim.log.levels.WARN)
    return
  end

  local title = type(opts.title) == "string" and opts.title ~= "" and opts.title or "Menu"
  local prompt = type(opts.prompt) == "string" and opts.prompt ~= "" and opts.prompt or nil
  local footer_keys = { "<Esc>", "<CR>" }
  local line_prefix = "  "
  local horizontal_padding = 4
  local lines = {}
  if prompt then
    table.insert(lines, line_prefix .. prompt)
  end
  table.insert(lines, "")
  local first_option_row = #lines + 1
  local last_option_row = first_option_row + #options - 1
  for _, item in ipairs(options) do
    local key = item.key and ("[%s]"):format(item.key) or "   "
    table.insert(lines, ("%s%s %s"):format(line_prefix, key, item.label))
  end
  table.insert(lines, "")
  local max_height = math.max(6, math.min(#lines, vim.o.lines - 6))

  local menu_done = false
  ---@type snacks.win?
  local menu_win = nil
  local function close_menu()
    if menu_win and menu_win:valid() then
      menu_win:close()
    end
  end

  ---@param err string
  local function handle_error(err)
    if opts.on_error then
      opts.on_error(err)
      return
    end
    vim.notify(("Menu action failed: %s"):format(err), vim.log.levels.ERROR)
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
        handle_error(err)
      end
    end
  end

  local function select_current_row()
    if not menu_win or not menu_win:valid() then
      return
    end
    local cursor = vim.api.nvim_win_get_cursor(menu_win.win)
    local index = cursor[1] - first_option_row + 1
    if index < 1 or index > #options then
      return
    end
    finish_menu(options[index].action)
  end

  ---@param row number
  ---@return number
  local function clamp_row(row)
    return math.max(first_option_row, math.min(row, last_option_row))
  end

  ---@param row number
  local function set_row(row)
    if not menu_win or not menu_win:valid() then
      return
    end
    pcall(vim.api.nvim_win_set_cursor, menu_win.win, { clamp_row(row), 0 })
  end

  ---@param delta number
  local function move_row(delta)
    if not menu_win or not menu_win:valid() then
      return
    end
    local cursor = vim.api.nvim_win_get_cursor(menu_win.win)
    set_row(cursor[1] + delta)
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
    ["<CR>"] = {
      "<CR>",
      select_current_row,
      mode = "n",
      nowait = true,
      desc = "Select",
    },
    ["j"] = {
      "j",
      function()
        move_row(1)
      end,
      mode = "n",
      nowait = true,
      desc = "Next option",
    },
    ["<Down>"] = {
      "<Down>",
      function()
        move_row(1)
      end,
      mode = "n",
      nowait = true,
      desc = "Next option",
    },
    ["k"] = {
      "k",
      function()
        move_row(-1)
      end,
      mode = "n",
      nowait = true,
      desc = "Previous option",
    },
    ["<Up>"] = {
      "<Up>",
      function()
        move_row(-1)
      end,
      mode = "n",
      nowait = true,
      desc = "Previous option",
    },
    ["gg"] = {
      "gg",
      function()
        set_row(first_option_row)
      end,
      mode = "n",
      nowait = true,
      desc = "First option",
    },
    ["G"] = {
      "G",
      function()
        set_row(last_option_row)
      end,
      mode = "n",
      nowait = true,
      desc = "Last option",
    },
  }

  for key, item in pairs(seen_keys) do
    keys[key] = {
      item.key,
      function()
        finish_menu(item.action)
      end,
      mode = "n",
      nowait = true,
      desc = item.label,
    }
  end

  local max_line_width = vim.api.nvim_strwidth(title)
  for _, line in ipairs(lines) do
    max_line_width = math.max(max_line_width, vim.api.nvim_strwidth(line))
  end
  local footer_width = 1
  for _, footer_key in ipairs(footer_keys) do
    local footer_item = keys[footer_key]
    if footer_item then
      local keymap = footer_item[1]
      local desc = footer_item.desc or keymap
      footer_width = footer_width + vim.api.nvim_strwidth(keymap) + 2
      footer_width = footer_width + vim.api.nvim_strwidth(desc) + 2
    end
  end
  footer_width = footer_width + 1
  local max_width =
    math.max(32, math.min(math.max(max_line_width, footer_width) + horizontal_padding, vim.o.columns - 6))

  menu_win = Snacks.win({
    border = "rounded",
    bo = {
      bufhidden = "wipe",
      buftype = "nofile",
      modifiable = false,
      readonly = true,
      swapfile = false,
      filetype = opts.filetype,
    },
    enter = true,
    focusable = true,
    footer_keys = footer_keys,
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
      vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = win.buf,
        callback = function()
          if not win:valid() then
            return
          end
          local cursor = vim.api.nvim_win_get_cursor(win.win)
          local row = clamp_row(cursor[1])
          if row ~= cursor[1] then
            pcall(vim.api.nvim_win_set_cursor, win.win, { row, 0 })
          end
        end,
      })
    end,
  })
end

return M
