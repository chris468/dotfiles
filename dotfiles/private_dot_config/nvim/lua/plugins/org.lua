local uv = vim.uv or vim.loop

local session_org_dir
local configured_org_dir
local capture_templates = {
  t = {
    description = "Task",
    template = "* TODO %?\n  %u",
  },
}

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

local function prompt_org_dir()
  local input = vim.fn.input("Org notes path: ", vim.fn.expand("~"), "dir")
  if input == nil or input == "" then
    vim.notify("Org notes path is required", vim.log.levels.ERROR)
    return nil
  end

  local dir = vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(input), ":p"))
  if not path_exists(dir) then
    vim.notify(("Org notes path does not exist: %s"):format(dir), vim.log.levels.ERROR)
    return nil
  end

  return dir
end

local function ensure_org_setup()
  if not session_org_dir then
    session_org_dir = prompt_org_dir()
  end
  if not session_org_dir then
    return nil
  end

  if configured_org_dir == session_org_dir then
    return session_org_dir
  end

  require("orgmode").setup({
    org_agenda_files = { session_org_dir .. "/**/*.org" },
    org_capture_templates = capture_templates,
    org_default_notes_file = session_org_dir .. "/inbox.org",
    ui = {
      input = {
        use_vim_ui = true,
      },
      menu = {
        handler = org_menu_handler,
      },
    },
  })
  configured_org_dir = session_org_dir

  return session_org_dir
end

local function run_org_subcommand(args)
  if not ensure_org_setup() then
    return
  end
  vim.cmd({
    cmd = "Org",
    args = args,
  })
end

local function run_org_action(action)
  if not ensure_org_setup() then
    return
  end
  require("orgmode").action(action)
end

local function open_org_inbox()
  local dir = ensure_org_setup()
  if not dir then
    return
  end
  vim.cmd.edit(dir .. "/inbox.org")
end

---@type LazyPluginSpec[]
return {
  {
    "nvim-orgmode/orgmode",
    ft = { "org" },
    cmd = { "Org" },
    keys = function()
      ---@type LazyKeysSpec[]
      local keys = {
        {
          "<leader>Na",
          function()
            run_org_subcommand({ "agenda" })
          end,
          desc = "Agenda",
        },
        {
          "<leader>Nt",
          function()
            run_org_action("org_mappings.todo_next_state")
          end,
          desc = "Todo next state",
        },
        { "<leader>NI", open_org_inbox, desc = "Inbox" },
      }

      local template_keys = vim.tbl_keys(capture_templates)
      table.sort(template_keys)
      for _, key in ipairs(template_keys) do
        local template_key = key
        local template = capture_templates[template_key] or {}
        local description = template.description or template_key
        table.insert(keys, {
          ("<leader>Nc%s"):format(template_key),
          function()
            run_org_subcommand({ "capture", template_key })
          end,
          desc = ("Capture: %s"):format(description),
        })
      end

      return keys
    end,
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
