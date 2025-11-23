if LazyVim.pick.picker.name ~= "snacks" then
  return {}
end

---@alias chris468.picker.Capabilities { ["root"|"cwd"|"global"]: boolean? }
---@alias chris468.picker.Status "root"|"cwd"|"same"|"global"

---@param picker snacks.Picker
---return (chris468.picker.Capabilities, string root, string cwd)|(false, nil, nil)
local function get_capabilities(picker)
  ---@type snacks.picker.Config|snacks.picker.grep.Config
  local opts = picker.opts or {}
  local result = {}

  result.global = opts.finder == "recent_files"
  result.cwd = not opts.buffers
    and vim.tbl_contains({
      "explorer",
      "files",
      "grep",
      "recent_files",
    }, opts.finder)
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

return {
  { "uga-rosa/utf8.nvim" },
  {
    "snacks.nvim",
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
            keys = {
              ["<C-/>"] = { "toggle_help_input", mode = "i" },
              ["<C-_>"] = { "toggle_help_input", mode = "i" },
              ["<C-\\>c"] = {
                "toggle_cwd",
                mode = { "n", "i" },
              },
              ["<C-\\>d"] = { "inspect", mode = { "n", "i" } },
              ["<C-\\>f"] = { "toggle_follow", mode = { "i", "n" } },
              ["<C-\\>h"] = { "toggle_hidden", mode = { "i", "n" } },
              ["<C-\\>i"] = { "toggle_ignored", mode = { "i", "n" } },
              ["<C-\\>r"] = { "toggle_regex", mode = { "i", "n" } },
              ["<C-\\>m"] = { "toggle_maximize", mode = { "i", "n" } },
              ["<C-\\>p"] = { "toggle_preview", mode = { "i", "n" } },
              ["<C-\\>w"] = { "cycle_win", mode = { "i", "n" } },
              ["<C-j>"] = false,
              ["<C-k>"] = false,
              ["<a-c>"] = false,
              ["<a-d>"] = false,
              ["<a-f>"] = false,
              ["<a-h>"] = false,
              ["<a-i>"] = false,
              ["<a-r>"] = false,
              ["<a-m>"] = false,
              ["<a-p>"] = false,
              ["<a-w>"] = false,
            },
          },
          list = {
            keys = {
              ["<C-/>"] = { "toggle_help_input" },
              ["<C-_>"] = { "toggle_help_input" },
              ["<C-\\>c"] = {
                "toggle_cwd",
                mode = { "n", "i" },
              },
              ["<C-\\>d"] = "inspect",
              ["<C-\\>f"] = "toggle_follow",
              ["<C-\\>h"] = "toggle_hidden",
              ["<C-\\>i"] = "toggle_ignored",
              ["<C-\\>m"] = "toggle_maximize",
              ["<C-\\>p"] = "toggle_preview",
              ["<C-\\>w"] = "cycle_win",
              ["<C-j>"] = false,
              ["<C-k>"] = false,
              ["<a-c>"] = false,
              ["<a-d>"] = false,
              ["<a-f>"] = false,
              ["<a-h>"] = false,
              ["<a-i>"] = false,
              ["<a-m>"] = false,
              ["<a-p>"] = false,
              ["<a-w>"] = false,
            },
          },
        },
      },
    },
  },
}
