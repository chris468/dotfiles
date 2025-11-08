local command = require("chris468.util.keymap").cmd
local Object = require("plenary").class

---@class chris468.util.Terminal
---@field setup fun()
---@field toggle fun(self: chris468.util.Terminal, opts: chris468.util.Terminal.ToggleOpts)
---@field background_command fun(self: chris468.util.Terminal, cmd: string, opts?: chris468.util.Terminal.BackgroundOpts)
---@field toggle_navigation_mappings fun(self: chris468.util.Terminal)
---@field extend fun(self: chris468.util.Terminal): chris468.util.Terminal
---@field protected _abstract fun(method: string)
---@field protected _background_config table
---@field private _enable_navigation_mappings fun(bufnr: integer)
---@field private _disable_navigation_mappings fun(bufnr: integer)
local Terminal = Object:extend()

---@class chris468.util.Terminal.ToggleOpts
---@field count number
---@field name? string

function Terminal:toggle(opts) ---@diagnostic disable-line: unused-local
  Terminal._abstract("toggle")
end

---@class chris468.util.Terminal.BackgroundOpts
---@field display_name? string

function Terminal:background_command(cmd, opts) ---@diagnostic disable-line: unused-local
  Terminal._abstract("background_command")
end

function Terminal._abstract(method)
  error("abstract method: " .. method)
end

---@private
Terminal._navigation_mappings = {
  { "<C-H>", command("TmuxNavigateLeft"), desc = "Navigate left", mode = "t" },
  { "<C-J>", command("TmuxNavigateDown"), desc = "Navigate down", mode = "t" },
  { "<C-K>", command("TmuxNavigateUp"), desc = "Navigate up", mode = "t" },
  { "<C-L>", command("TmuxNavigateRight"), desc = "Navigate right", mode = "t" },
}

function Terminal._enable_navigation_mappings(bufnr)
  vim.b[bufnr].chris468_terminal_navigation_mappings = true
  for _, mapping in ipairs(Terminal._navigation_mappings) do
    vim.keymap.set(mapping.mode, mapping[1], mapping[2], {
      desc = mapping.desc,
      buffer = bufnr,
    })
  end
end

function Terminal._disable_navigation_mappings(bufnr)
  vim.b[bufnr].chris468_terminal_navigation_mappings = false
  for _, mapping in ipairs(Terminal._navigation_mappings) do
    vim.keymap.set(mapping.mode, mapping[1], mapping[1], {
      buffer = bufnr,
      remap = false,
    })
  end
end

function Terminal:toggle_navigation_mappings()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].buftype ~= "terminal" then
    return
  end

  local enable = not vim.b[bufnr].chris468_terminal_navigation_mappings
  if enable then
    self._enable_navigation_mappings(bufnr)
  else
    self._disable_navigation_mappings(bufnr)
  end
end

function Terminal.setup()
  vim.api.nvim_create_autocmd("TermEnter", {
    callback = function(arg)
      local bufnr = arg.buf
      if vim.b[bufnr].chris468_terminal_mappings == nil then
        Terminal._enable_navigation_mappings(bufnr)
      end
    end,
    group = vim.api.nvim_create_augroup("chris468.terminal", { clear = true }),
  })
end

local function should_show_stdout(str)
  local patterns = {
    "\27%[?[0-9;]*[a-zA-Z]", -- console code
    "\27].-\27\\", -- OSC sequence
    "%s+", -- whitespace
  }

  for _, pattern in ipairs(patterns) do
    str = str:gsub(pattern, "")
  end

  return str ~= ""
end

local function on_create(term)
  vim.b[term.bufnr].chris468_terminal_navigation_mappings = false
  vim.keymap.set("n", "q", function()
    term:close()
  end)
  vim.keymap.set("n", "<Esc>", function()
    term:close()
  end, { buffer = term.bufnr, nowait = true })
  vim.keymap.set({ "n", "t" }, "<C-/>", function()
    term:close()
  end, { buffer = term.bufnr, nowait = true })
end

local function on_stdout(term, _, data)
  if not term:is_open() then
    for _, line in ipairs(data) do
      if should_show_stdout(line) then
        term:open()
      end
    end
  end
end

local function on_stderr(term)
  if not term:is_open() then
    term:open()
  end
end

local function on_exit(term, _, exit_code)
  if exit_code ~= 0 then
    vim.notify(term.display_name .. " exited with code " .. exit_code, vim.log.levels.ERROR)
    if not term:is_open() then
      term:open()
    end
  else
    vim.notify(term.display_name .. " completed.", vim.log.levels.INFO)
    term:close()
  end
end

Terminal._background_config = {
  on_create = on_create,
  on_stdout = on_stdout,
  on_stderr = on_stderr,
  on_exit = on_exit,
  hidden = false,
  direction = "float",
  display_name = "Background Command",
  float_opts = {
    border = "curved",
    width = function()
      return math.floor(vim.o.columns * 0.95)
    end,
    height = function()
      return math.floor(vim.o.lines * 0.33)
    end,
    -- centered by default so exclude column
    row = function()
      return math.floor(vim.o.lines * 0.67) - 3
    end,
    title_pos = "center",
  },
  close_on_exit = false,
}

return Terminal
