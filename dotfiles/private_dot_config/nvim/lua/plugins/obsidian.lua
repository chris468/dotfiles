local vault = require("util.vault")
local safe_keymap = require("util.safe_keymap")

local function workspace_name(path)
  local slug = path:gsub("[^%w]+", "-"):gsub("%-+", "-"):gsub("^%-", ""):gsub("%-$", "")
  if slug == "" then
    slug = "vault"
  end
  return ("vault-%s"):format(slug)
end

local function list_workspaces()
  local paths = {}
  local seen = {}
  local function add(path)
    if type(path) ~= "string" or path == "" or seen[path] then
      return
    end
    if vault.is_vault_path(path) then
      seen[path] = true
      table.insert(paths, path)
    end
  end

  add(vault.get_current())
  for _, path in ipairs(vault.get_mru()) do
    add(path)
  end
  add(vim.fn.getcwd())

  local workspaces = {}
  for _, path in ipairs(paths) do
    table.insert(workspaces, {
      name = workspace_name(path),
      path = path,
    })
  end
  return workspaces
end

local function ensure_workspace(path)
  local ok_obsidian, obsidian = pcall(require, "obsidian")
  if not ok_obsidian then
    return false
  end

  local ok_client, client = pcall(obsidian.get_client)
  if not ok_client or not client or not client.opts then
    return false
  end

  client.opts.workspaces = list_workspaces()
  local target = workspace_name(path)
  if vim.fn.exists(":ObsidianWorkspace") == 2 then
    vim.cmd(("ObsidianWorkspace %s"):format(target))
  end

  return true
end

---@param context string
---@param callback fun()
local function with_vault(context, callback)
  vault.resolve_async({
    context = context,
    allow_prompt = true,
  }, function(path)
    if not path then
      return
    end

    require("lazy").load({ plugins = { "obsidian.nvim" } })
    if vim.fn.exists(":ObsidianNew") ~= 2 then
      vim.notify("Obsidian commands are unavailable", vim.log.levels.ERROR)
      return
    end

    ensure_workspace(path)
    callback()
  end)
end

local function find_recent_notes()
  vault.resolve_async({
    context = "recent notes",
    allow_prompt = true,
  }, function(path)
    if not path then
      return
    end
    if LazyVim.pick.picker.name == "snacks" then
      Snacks.picker.files({
        cwd = path,
        ft = "markdown",
        hidden = true,
        title = "Recent Notes",
      })
      return
    end
    require("telescope.builtin").oldfiles({
      cwd_only = true,
      cwd = path,
    })
  end)
end

local note_mappings = {
  {
    candidates = { "<leader>Nn", "<leader>NN" },
    desc = "New note",
    action = function()
      with_vault("new note", function()
        vim.cmd("ObsidianNew")
      end)
    end,
  },
  {
    candidates = { "<leader>Nf", "<leader>NF" },
    desc = "Find note",
    action = function()
      with_vault("find note", function()
        vim.cmd("ObsidianQuickSwitch")
      end)
    end,
  },
  {
    candidates = { "<leader>Nt", "<leader>NT" },
    desc = "Today note",
    action = function()
      with_vault("today note", function()
        vim.cmd("ObsidianToday")
      end)
    end,
  },
  {
    candidates = { "<leader>Ny", "<leader>NY" },
    desc = "Yesterday note",
    action = function()
      with_vault("yesterday note", function()
        vim.cmd("ObsidianYesterday")
      end)
    end,
  },
  {
    candidates = { "<leader>Nm", "<leader>NM" },
    desc = "Tomorrow note",
    action = function()
      with_vault("tomorrow note", function()
        vim.cmd("ObsidianTomorrow")
      end)
    end,
  },
  {
    candidates = { "<leader>Nr", "<leader>NR" },
    desc = "Recent notes",
    action = find_recent_notes,
  },
  {
    candidates = { "<leader>Nv", "<leader>NV" },
    desc = "Pick vault",
    action = function()
      vault.resolve_async({
        context = "vault picker",
        allow_prompt = true,
        force_prompt = true,
      }, function(path)
        if not path then
          return
        end
        require("lazy").load({ plugins = { "obsidian.nvim" } })
        ensure_workspace(path)
        vim.notify(("Using vault: %s"):format(path), vim.log.levels.INFO)
      end)
    end,
  },
}

local function register_note_keymaps()
  for _, item in ipairs(note_mappings) do
    local key = safe_keymap.set_first_available("n", item.candidates, item.action, {
      desc = item.desc,
    })
    if not key then
      vim.notify(("Could not map note action: %s"):format(item.desc), vim.log.levels.WARN)
    end
  end
end

return {
  {
    "obsidian-nvim/obsidian.nvim",
    lazy = true,
    name = "obsidian.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    init = function()
      local group = vim.api.nvim_create_augroup("chris468.obsidian.detect", { clear = true })
      register_note_keymaps()
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        group = group,
        pattern = "*.md",
        callback = function(args)
          local detected = vault.find_vault_for_path(args.file)
          if not detected then
            return
          end
          vault.set_current(detected)
          require("lazy").load({ plugins = { "obsidian.nvim" } })
        end,
      })
    end,
    opts = function()
      return {
        workspaces = list_workspaces(),
        completion = {
          nvim_cmp = true,
          min_chars = 2,
        },
        picker = {
          name = "snacks.pick",
        },
      }
    end,
  },
}
