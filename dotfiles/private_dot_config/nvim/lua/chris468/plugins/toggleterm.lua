local terminal_id = {
  default = 1,
  lazygit = 2,
}

local function size(term)
  if term.direction == "horizontal" then
    return vim.o.lines * 0.25
  elseif term.direction == "vertical" then
    return vim.o.columns * 0.4
  end
end

--- @param allow_normal boolean?
local function map_keys(term, allow_normal)
  allow_normal = allow_normal == nil or allow_normal

  local has_tmux_navigation = vim.fn.exists(":TmuxNavigateLeft") ~= 0
  local is_split = term:is_split()
  local map_navigation = has_tmux_navigation and is_split

  local keys = {
    ["<esc><C-h>"] = { "<cmd>TmuxNavigateLeft<cr>", set = map_navigation },
    ["<esc><C-j>"] = { "<cmd>TmuxNavigateDown<cr>", set = map_navigation },
    ["<esc><C-k>"] = { "<cmd>TmuxNavigateUp<cr>", set = map_navigation },
    ["<esc><C-l>"] = { "<cmd>TmuxNavigateRight<cr>", set = map_navigation },
    ["<esc><esc>"] = { "<C-\\><C-N>", set = allow_normal, opts = { desc = "Normal mode", noremap = true } },
  }

  for key, spec in pairs(keys) do
    local cmd, set, opts = spec[1], spec.set, spec.opts or {}
    if set then
      vim.api.nvim_buf_set_keymap(term.bufnr, "t", key, cmd, opts)
    else
      pcall(vim.api.nvim_buf_del_keymap, term.bufnr, "t", key)
    end
  end
end

--- @param id number
--- @param display_name string
--- @param cmd string?
--- @param map_keys_once boolean?
--- @param allow_normal boolean?
local function create(id, display_name, cmd, map_keys_once, allow_normal)
  local Terminal = require("toggleterm.terminal").Terminal

  map_keys_once = map_keys_once or false
  allow_normal = allow_normal == nil or allow_normal

  local on_map_keys = function(term)
    map_keys(term, allow_normal)
  end

  local create_keys_when = map_keys_once and "on_create" or "on_open"

  return Terminal:new({
    id = id,
    display_name = display_name,
    cmd = cmd,
    [create_keys_when] = on_map_keys,
  })
end

local function default(direction)
  local function toggle()
    local term = create(terminal_id.default, "Terminal")
    term:toggle(nil, direction)
  end

  return toggle
end

local function any_modified_buffers()
  local buffers = vim.api.nvim_list_bufs()
  for _, buffer in ipairs(buffers) do
    if vim.bo[buffer].modified then
      return true
    end
  end

  return false
end

local function lazygit()
  local function toggle()
    local term = create(terminal_id.lazygit, "Lazygit", "lazygit", true, false)
    term:toggle(nil, "float")
    if any_modified_buffers() then
      vim.notify("Some files have unsaved changes", vim.log.levels.WARN)
    end
  end

  return toggle
end

local function toggle()
  local tt = require("toggleterm")
  local terms = require("toggleterm.terminal").get_all(true)
  if not terms or #terms == 0 then
    default()()
  else
    tt.toggle()
  end
end

return {
  "akinsho/toggleterm.nvim",
  cmd = {
    "ToggleTerm",
    "ToggleTermToggleAll",
    "TermExec",
    "TermSelect",
    "ToggleTermSendCurrentLine",
    "ToggleTermSendVisualLines",
    "ToggleTermSendVisualSelection",
    "ToggleTermSetName",
  },
  keys = {
    { "<C-\\>", toggle, mode = { "n", "t" }, desc = "Toggle last terminal" },
    { "<leader>ft", "<cmd>TermSelect<CR>", desc = "Terminal" },
    { "<leader>mf", default("float"), desc = "Float deafult terminal" },
    { "<leader>mh", default("horizontal"), desc = "Horizontal deafult terminal" },
    { "<leader>mm", default(), desc = "Toggle default terminal" },
    { "<leader>mv", default("vertical"), desc = "Vertical deafult terminal" },
    { "<leader>gg", lazygit(), desc = "Lazygit" },
  },
  opts = {
    direction = "float",
    float_opts = {
      border = "rounded",
      title_pos = "center",
    },
    size = size,
  },
}