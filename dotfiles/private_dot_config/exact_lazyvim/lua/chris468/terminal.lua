local lazyvim = {
  util = require("lazyvim.util"),
}
local M = {}

---@type Chris468TermOpts
local defaults = {
  direction = lazyvim.util.has("toggleterm.nvim") and lazyvim.util.opts("toggleterm.nvim").direction or "float",
  display_name = "ToggleTerm",
  remain_on_error = false,
  warn_on_unsaved = false,
}

---@class Chris468TermConfig
---@field overrides? table<1|string, fun(cmd: string|string[]|nil, opts: Chris468TermOpts, match?: string|string[])>

---@type Chris468TermConfig
local config = {
  overrides = {},
}

local T = {
  next = 1 --[[@type integer]],
  terminals = {} --[[@type table<string, integer>]],
}

---@param opts Chris468TermOpts
---@return string
local function terminal_key(opts)
  return opts.display_name .. "|" .. opts.direction
end

---@param buffer integer
---@param esc_esc? boolean
---@param ctrl_hjkl? boolean
---@param direction? "float" | "horizontal" | "vertical
local function add_mappings(buffer, esc_esc, ctrl_hjkl, direction)
  esc_esc = esc_esc ~= false
  if ctrl_hjkl == nil then
    ctrl_hjkl = direction and direction ~= "float"
  end

  local keys = {
    ["<C-h>"] = { enable = ctrl_hjkl },
    ["<C-j>"] = { enable = ctrl_hjkl },
    ["<C-k>"] = { enable = ctrl_hjkl },
    ["<C-l>"] = { enable = ctrl_hjkl },
    ["<esc>"] = { enable = esc_esc },
  }

  for k, opt in pairs(keys) do
    if not opt.enable then
      --- The keys are globally configured in LazyVim's base keyamps.lua.
      --- Disabling means setting to themselves.
      vim.keymap.set("t", k, k, { nowait = true, buffer = buffer })
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

---@param cmd? string
---@param opts Chris468TermOpts
local function create(cmd, opts)
  local Terminal = require("toggleterm.terminal").Terminal

  local key = terminal_key(opts)
  if not T.terminals[key] then
    T.terminals[key] = T.next
    T.next = T.next + 1
  end
  local id = T.terminals[key]

  ---@param term Terminal
  local on_create = function(term)
    add_mappings(term.bufnr, opts.esc_esc, opts.ctrl_hjkl, term.direction)
    if opts.warn_on_unsaved then
      if any_modified_buffers() then
        vim.notify("Some files have unsaved changes", vim.log.levels.WARN)
      end
    end
  end

  ---@type TermCreateArgs
  local term_opts = {
    display_name = opts.display_name,
    cmd = cmd --[[@as string]],
    on_create = on_create,
    id = id,
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

---param cmd? string
---param opts Chris468TermOpts
local function override_opts(cmd, opts)
  local override = config.overrides[1]
  local match = cmd
  if config.overrides[cmd] then
    override = config.overrides[cmd]
  elseif cmd then
    local keys = vim.tbl_keys(config.overrides)
    table.sort(keys, function(a, b)
      if type(a) ~= type(b) then
        return type(a) < type(b)
      end
      return a > b
    end)
    for _, k in ipairs(keys) do
      local m = type(k) == "string" and { cmd:match(k) }
      if m and not vim.tbl_isempty(m) then
        override = config.overrides[k]
        match = m
        break
      end
    end
  end

  if override then
    override(cmd, opts, match)
  end

  return opts
end

---@param cmd? string|string[]|fun():(string|string[])
---@param opts? Chris468TermOpts
function M.open(cmd, opts)
  if type(cmd) == "function" then
    cmd = cmd()
  end
  if type(cmd) == "table" then
    cmd = table.concat(
      vim.tbl_map(function(c)
        return vim.fn.shellescape(c)
      end, cmd),
      " "
    )
  end

  opts = override_opts(cmd, vim.tbl_extend("keep", opts or {}, { display_name = cmd }, defaults))
  return create(cmd, opts):toggle(nil, opts and opts.direction or nil)
end

---@param opts? Chris468TermConfig
function M.setup(opts)
  config = vim.tbl_extend("keep", opts or {}, config or {})
  lazyvim.util.terminal.open = M.open
end

return M
