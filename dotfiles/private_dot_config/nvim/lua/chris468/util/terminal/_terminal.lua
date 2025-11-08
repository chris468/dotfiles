local command = require("chris468.util.keymap").cmd
local Object = require("plenary").class

---@class chris468.util.Terminal
---@field extend fun(self: chris468.util.Terminal): chris468.util.Terminal
local Terminal = Object:extend()

---@class chris468.util.Terminal.ToggleOpts
---@field count number
---@field name? string

---@param opts chris468.util.Terminal.ToggleOpts
function Terminal:toggle(opts) ---@diagnostic disable-line: unused-local
  Terminal._abstract("toggle")
end

--- @param cmd string
--- @param display_name? string
function Terminal:background_command(cmd, display_name) ---@diagnostic disable-line: unused-local
  Terminal._abstract("background_command")
end

---@protected
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

---@private
---@param bufnr integer
function Terminal._enable_navigation_mappings(bufnr)
  vim.b[bufnr].chris468_terminal_navigation_mappings = true
  for _, mapping in ipairs(Terminal._navigation_mappings) do
    vim.keymap.set(mapping.mode, mapping[1], mapping[2], {
      desc = mapping.desc,
      buffer = bufnr,
    })
  end
end

---@private
---@param bufnr integer
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

return Terminal
