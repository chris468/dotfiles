local terminal_id = {
  default = 1,
  lazygit = 2,
  chezmoi = 3,
}

-- local function nu_or_default()
--   local nu_path = vim.fn.exepath("nu")
--   if nu_path == "" then
--     return nil
--   end
--   return nu_path .. " -i"
-- end

local terminals = {
  default = {
    id = terminal_id.default,
    -- cmd = nu_or_default(),
    display_name = "Terminal",
  },
  lazygit = {
    id = terminal_id.lazygit,
    display_name = "Lazygit",
    cmd = "lazygit",
    map_keys_once = true,
    allow_normal = false,
    warn_on_unsaved = true,
  },
  chezmoi_apply = {
    id = terminal_id.lazygit,
    display_name = "Chezmoi (dotfiles) - apply changes",
    cmd = "chezmoi apply",
    map_keys_once = true,
    allow_normal = false,
    remain_on_error = true,
    warn_on_unsaved = true,
  },
  chezmoi_add = {
    id = terminal_id.lazygit,
    display_name = "Chezmoi (dotfiles) - add file",
    cmd = function()
      local filename = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
      return "chezmoi add '" .. filename .. "'"
    end,
    map_keys_once = true,
    allow_normal = false,
    remain_on_error = true,
    warn_on_unsaved = true,
  },
}

local function size(term)
  if term.direction == "horizontal" then
    return vim.o.lines * 0.25
  elseif term.direction == "vertical" then
    return vim.o.columns * 0.4
  end
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

--- @param allow_normal boolean?
local function map_keys(term, allow_normal)
  allow_normal = allow_normal == nil or allow_normal

  local has_tmux_navigation = vim.fn.exists(":TmuxNavigateLeft") ~= 0
  local is_split = term:is_split()
  local map_navigation = has_tmux_navigation and is_split

  local keys = {
    ["<C-h>"] = { "<C-h>", set = not map_navigation, mode = "n", opts = { noremap = true } },
    ["<C-j>"] = { "<C-j>", set = not map_navigation, mode = "n", opts = { noremap = true } },
    ["<C-k>"] = { "<C-k>", set = not map_navigation, mode = "n", opts = { noremap = true } },
    ["<C-l>"] = { "<C-l>", set = not map_navigation, mode = "n", opts = { noremap = true } },
    ["<esc><C-h>"] = { "<cmd>TmuxNavigateLeft<cr>", set = map_navigation },
    ["<esc><C-j>"] = { "<cmd>TmuxNavigateDown<cr>", set = map_navigation },
    ["<esc><C-k>"] = { "<cmd>TmuxNavigateUp<cr>", set = map_navigation },
    ["<esc><C-l>"] = { "<cmd>TmuxNavigateRight<cr>", set = map_navigation },
    ["<esc><esc>"] = { "<C-\\><C-N>", set = allow_normal, opts = { desc = "Normal mode", noremap = true } },
  }

  for key, spec in pairs(keys) do
    local cmd, set, mode, opts = spec[1], spec.set, spec.mode or "t", spec.opts or {}
    if set then
      vim.api.nvim_buf_set_keymap(term.bufnr, mode, key, cmd, opts)
    else
      pcall(vim.api.nvim_buf_del_keymap, term.bufnr, mode, key)
    end
  end
end

--- @class TermOpts
--- @field id number
--- @field display_name string
--- @field cmd (string | fun() : string?)?
--- @field map_keys_once boolean?
--- @field allow_normal boolean?
--- @field remain_on_error boolean?
--- @field warn_on_unsaved boolean?

local term_defaults = {
  map_keys_once = false,
  allow_normal = true,
  remain_on_error = false,
  warn_on_unsaved = false,
}

--- @param opts TermOpts?
local function create(opts)
  local Terminal = require("toggleterm.terminal").Terminal

  opts = vim.tbl_extend("keep", opts or {}, term_defaults)
  if type(opts.cmd) == "function" then
    opts.cmd = opts.cmd()
  end

  local on_map_keys = function(term)
    map_keys(term, opts.allow_normal)
  end

  local create_keys_when = opts.map_keys_once and "on_create" or "on_open"
  local term_opts = {
    id = opts.id,
    display_name = opts.display_name,
    cmd = opts.cmd,
    [create_keys_when] = on_map_keys,
  }

  if opts.warn_on_unsaved then
    term_opts.on_create = function()
      if any_modified_buffers() then
        vim.notify("Some files have unsaved changes", vim.log.levels.WARN)
      end
    end
  end

  if opts.remain_on_error then
    term_opts.on_exit = function(t, _, exit_code, _)
      if exit_code ~= 0 then
        t.close_on_exit = false
        vim.notify("`" .. t.cmd .. "` failed with exit code " .. exit_code, vim.log.levels.ERROR)
      end
    end
  end

  return Terminal:new(term_opts)
end

--- @param opts TermOpts
--- @param direction string?
--- | "'horizontal'"
--- | "'vertical'"
--- | "'float'"
--- @return function toggle
local function toggle(opts, direction)
  return function()
    local term = create(opts)
    term:toggle(nil, direction)
  end
end

local function default_toggle(default_opts)
  return function()
    local tt = require("toggleterm")
    local terms = require("toggleterm.terminal").get_all(true)
    local _toggle = not terms or #terms == 0 and toggle(default_opts) or tt.toggle
    _toggle()
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
    { "<C-\\>", default_toggle(terminals.default), mode = { "n", "t" }, desc = "Toggle last terminal" },
    { "<leader>Da", toggle(terminals.chezmoi_apply, "horizontal"), desc = "Apply chezmoi dotfiles" },
    { "<leader>DA", toggle(terminals.chezmoi_add, "horizontal"), desc = "Add current file to chezmoi dotfiles" },
    { "<leader>ft", "<cmd>TermSelect<CR>", desc = "Terminal" },
    { "<leader>gg", toggle(terminals.lazygit, "float"), desc = "Lazygit" },
    { "<leader>mf", toggle(terminals.default, "float"), desc = "Float deafult terminal" },
    { "<leader>mh", toggle(terminals.default, "horizontal"), desc = "Horizontal deafult terminal" },
    { "<leader>mm", toggle(terminals.default), desc = "Toggle default terminal" },
    { "<leader>mv", toggle(terminals.default, "vertical"), desc = "Vertical deafult terminal" },
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
