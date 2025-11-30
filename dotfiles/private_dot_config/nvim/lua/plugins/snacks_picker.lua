local getenv = require("os").getenv

if LazyVim.pick.picker.name ~= "snacks" then
  return {}
end

---@alias chris468.picker.Capabilities { ["root"|"cwd"|"global"]: boolean? }
---@alias chris468.picker.Status "root"|"cwd"|"same"|"global"

---@param picker snacks.Picker
---@return (chris468.picker.Capabilities, string root, string cwd)|(false, nil, nil)
local function get_capabilities(picker)
  ---@type snacks.picker.Config|snacks.picker.grep.Config
  local opts = picker.opts or {}
  local result = {}

  result.global = opts.source == "recent"
  result.cwd = not opts.buffers
    and vim.tbl_contains({
      "explorer",
      "files",
      "grep",
      "recent",
    }, opts.source)
  result.root = result.cwd

  if vim.tbl_contains(result, true) then
    local root = LazyVim.root({ buf = picker.input.filter.current_buf, normalize = true })
    local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or ".")
    return result, root, cwd
  end

  return false, nil, nil
end

---@param current_state chris468.picker.Status
---@param capabilities chris468.picker.Capabilities
---@param root string
---@param cwd string
---@return chris468.picker.Status|boolean
local function get_next_picker_state(current_state, capabilities, root, cwd)
  local same = capabilities.root and capabilities.cwd and root == cwd
  ---@type { [string]: chris468.picker.Status|boolean }
  local transition = {
    global = "root",
    root = same and "global" or "cwd",
    cwd = "global",
    same = "global",
  }

  ---@type chris468.picker.Status|boolean
  local state = current_state
  repeat
    local prev = state
    state = transition[state]
    transition[prev] = false
  until not state or capabilities[state]

  if same and (state == "root" or state == "cwd") then
    state = "same"
  end

  return state
end

---@param picker snacks.Picker
---@return chris468.picker.Status
local function get_picker_state(picker, capabilities, root, cwd)
  if capabilities.global and not picker.input.filter.opts.cwd then
    return "global"
  end

  local picker_cwd = picker:cwd()

  if capabilities.root and capabilities.cwd and root == cwd then
    return "same"
  end

  if capabilities.root and picker_cwd == root then
    return "root"
  end

  return "cwd"
end
---
---@param picker snacks.Picker
---@param state chris468.picker.Status
local function set_picker_title(picker, state)
  local utf8 = require("utf8")

  local title = picker.title
  local offset = utf8.offset(title, -2)
  if not offset then
    return
  end
  title = title:sub(offset, offset) == " " and title:sub(0, offset - 1) or title

  local suffix = {
    same = " =",
    cwd = " ",
    root = " ",
    global = " ",
  }

  title = ("%s%s"):format(title, suffix[state])

  if picker.title ~= title then
    picker.title = title
    picker:update_titles()
  end
end

---@param picker snacks.Picker
local function toggle_cwd(picker)
  local capabilities, root, cwd = get_capabilities(picker)
  if not capabilities then
    return
  end
  ---@cast root string
  ---@cast cwd string

  local prev_state = get_picker_state(picker, capabilities, root, cwd)
  local state = get_next_picker_state(prev_state, capabilities, root, cwd)
  if not state then
    return
  end
  ---@cast state chris468.picker.Status

  if capabilities.global then
    picker.input.filter.opts.cwd = state ~= "global"
  end

  if state == "root" then
    cwd = root
  end

  if state == prev_state and cwd == picker:cwd() then
    return
  end

  set_picker_title(picker, state)
  if state ~= "global" then
    picker:set_cwd(cwd)
  end

  picker:find()
end

---@param picker snacks.Picker
local function update_picker_title(picker)
  local capabilities, root, cwd = get_capabilities(picker)
  if not capabilities then
    return
  end

  local state = get_picker_state(picker, capabilities, root, cwd)
  set_picker_title(picker, state)
end

---@type snacks.picker.Config
local plugin_source = {
  formatters = { file = { filename_first = true } },
  layout = { preset = "vertical", hidden = { "preview" } },
  icons = { files = { enabled = false } },
  preview = "file",
  source = "plugins",
  title = "Lazy plugins",
  confirm = { "picker_files" },
  win = {
    input = {
      keys = {
        ["<C-G>"] = { "picker_grep", mode = { "n", "i" } },
      },
    },
    list = {
      keys = {
        ["<C-G>"] = "picker_grep",
      },
    },
  },
}

function plugin_source.finder()
  require("lazy.view.colors").setup()
  return vim.tbl_map(function(p)
    return {
      text = p.name,
      file = p.dir,
      loaded = p._.loaded ~= nil,
      is_local = p._.is_local ~= nil,
    }
  end, require("lazy").plugins())
end

function plugin_source.format(item, picker)
  local icons = require("lazy.core.config").options.ui.icons
  ---@type snacks.picker.Highlight[]
  local ret = {
    { item.loaded and icons.loaded or icons.not_loaded, item.is_local and "LazyLocal" or "LazySpecial" },
    { " " },
  }

  vim.list_extend(ret, Snacks.picker.format.file(item, picker))

  return ret
end

LazyVim.on_load("snacks.nvim", function()
  Snacks.picker.sources.plugin = plugin_source
end)

---@param ...table<string|string[], false|string[]>
local function mappings(...)
  local common_mappings = {
    [{ "<C-/>", "<C-_>" }] = { "toggle_help_input", mode = { "i", "n" } },
    ["<C-\\>c"] = {
      "toggle_cwd",
      mode = { "n", "i" },
    },
    ["<C-\\>d"] = { "inspect", mode = { "n", "i" } },
    ["<C-\\>f"] = { "toggle_follow", mode = { "i", "n" } },
    ["<C-\\>h"] = { "toggle_hidden", mode = { "i", "n" } },
    ["<C-\\>i"] = { "toggle_ignored", mode = { "i", "n" } },
    ["<C-\\>m"] = { "toggle_maximize", mode = { "i", "n" } },
    ["<C-\\>p"] = { "toggle_preview", mode = { "i", "n" } },
    ["<C-\\>r"] = { "toggle_regex", mode = { "i", "n" } },
    ["<C-\\>w"] = { "cycle_win", mode = { "i", "n" } },
  }
  local disabled_mappings = {
    [{
      "<C-j>",
      "<C-k>",
      "<a-c>",
      "<a-d>",
      "<a-f>",
      "<a-h>",
      "<a-i>",
      "<a-m>",
      "<a-p>",
      "<a-r>",
      "<a-w>",
    }] = false,
  }

  local function flatten(...)
    return vim.iter({ ... }):fold({}, function(result, ms)
      for ks, v in pairs(ms) do
        for _, k in ipairs(type(ks) == "string" and { ks } or ks) do
          result[k] = v
        end
      end
      return result
    end)
  end

  return flatten(common_mappings, disabled_mappings, ...)
end

return {
  { "uga-rosa/utf8.nvim", lazy = true },
  {
    "chris468-utils",
    dependencies = {
      "plenary.nvim",
      "utf8.nvim",
    },
    dir = (getenv("XDG_DATA_HOME") or vim.expand("~/.local/share")) .. "/chris468/neovim/plugins/utils",
    lazy = true,
  },
  {
    "snacks.nvim",
    dependencies = { "chris468-utils" },
    keys = {
      {
        "<leader>si",
        function()
          local opts = {}
          local filename = require("chris468-utils.unicode").download("unicode")
          if filename then
            opts.custom_sources = { unicode = filename }
          end
          Snacks.picker.icons(opts)
        end,
        desc = "Icons",
      },
      {
        "<leader>sp",
        function()
          Snacks.picker.plugin()
        end,
        desc = "Lazy plugins",
      },
      {
        "<leader>sP",
        function()
          Snacks.picker.lazy()
        end,
        desc = "Lazy plugin specs",
      },
    },
    ---@module 'snacks'
    ---@type snacks.Config
    opts = {
      picker = {
        actions = {
          toggle_cwd = toggle_cwd,
        },
        on_show = update_picker_title,
        win = {
          input = {
            keys = mappings(),
          },
          list = {
            keys = mappings(),
          },
        },
      },
    },
  },
}
