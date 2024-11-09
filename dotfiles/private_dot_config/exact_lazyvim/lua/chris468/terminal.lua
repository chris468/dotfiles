local lazyvim = {
  util = require("lazyvim.util"),
}
local M = {}

---@param buffer integer
---@param esc_esc boolean
---@param ctrl_hjkl boolean
---@param direction? "float" | "horizontal" | "vertical
local function add_mappings(buffer, esc_esc, ctrl_hjkl, direction)
  esc_esc = esc_esc ~= false
  if ctrl_hjkl == nil then
    ctrl_hjkl = direction ~= "float" and lazyvim.util.has("vim-tmux-navigator")
  end

  local keys = {
    ["<C-h>"] = { "<C-h>", set = not ctrl_hjkl, mode = "n", opts = { noremap = true } },
    ["<C-j>"] = { "<C-j>", set = not ctrl_hjkl, mode = "n", opts = { noremap = true } },
    ["<C-k>"] = { "<C-k>", set = not ctrl_hjkl, mode = "n", opts = { noremap = true } },
    ["<C-l>"] = { "<C-l>", set = not ctrl_hjkl, mode = "n", opts = { noremap = true } },
    ["<esc><C-h>"] = { "<cmd>TmuxNavigateLeft<cr>", set = ctrl_hjkl },
    ["<esc><C-j>"] = { "<cmd>TmuxNavigateDown<cr>", set = ctrl_hjkl },
    ["<esc><C-k>"] = { "<cmd>TmuxNavigateUp<cr>", set = ctrl_hjkl },
    ["<esc><C-l>"] = { "<cmd>TmuxNavigateRight<cr>", set = ctrl_hjkl },
    ["<esc><esc>"] = { "<C-\\><C-N>", set = esc_esc, opts = { desc = "Normal mode", noremap = true } },
  }

  for key, spec in pairs(keys) do
    local cmd, set, mode, opts = spec[1], spec.set, spec.mode or "t", spec.opts or {}
    if set then
      vim.api.nvim_buf_set_keymap(buffer, mode, key, cmd, opts)
    else
      pcall(vim.api.nvim_buf_del_keymap, buffer, mode, key)
    end
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

--- @class Chris468TermOpts : LazyTermOpts
--- @field direction? "float" | "horizontal" | "vertical
--- @field display_name? string
--- @field remain_on_error? boolean
--- @field warn_on_unsaved? boolean

---@type Chris468TermOpts
local defaults = {
  direction = "float",
  display_name = "Terminal",
  remain_on_error = false,
  warn_on_unsaved = false,
}

---@param cmd? string|string[]|fun():(string|string[])
---@param opts? Chris468TermOpts
local function create(cmd, opts)
  local Terminal = require("toggleterm.terminal").Terminal
  cmd = type(cmd) == "function" and cmd() or cmd
  if type(cmd) == "table" then
    cmd = table.concat(
      vim.tbl_map(function(c)
        return vim.fn.shellescape(c)
      end, cmd),
      " "
    )
  end
  opts = vim.tbl_extend("keep", opts or {}, { display_name = cmd }, defaults)

  ---@param term Terminal
  local on_create = function(term)
    add_mappings(term.bufnr, opts.esc_esc, opts.ctrl_hjkl, term.direction)
    if opts.warn_on_unsaved then
      if any_modified_buffers() then
        vim.notify("Some files have unsaved changes", vim.log.levels.WARN)
      end
    end
  end

  local term_opts = {
    display_name = opts.display_name,
    cmd = cmd --[[@as string]],
    on_create = on_create,
  }

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

---@param cmd? string|string[]|fun():(string|string[])
---@param opts? Chris468TermOpts
function M.open(cmd, opts)
  return create(cmd, opts):toggle(nil, opts and opts.direction or nil)
end

function M.setup()
  lazyvim.util.terminal.open = M.open
end

return M
