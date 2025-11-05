local cmd = require("chris468.util.keymap").cmd
local Object = require("plenary").class

---@class chris468.util.Terminal.Opts
---@field count? integer
---@field name? string

---@class chris468.util.Terminal.Mapping : vim.keymap.set.Opts
---@field mode? string|string[]
---@field lhs string
---@field rhs string|fun()

---@class chris468.util.Terminal
---@field toggle fun(opts: chris468.util.Terminal.Opts): chris468.util.Terminal
---@field toggle_mappings fun(bufnr?: integer)
---@field protected _abstract fun(method: string)
---@field mappings chris468.util.Terminal.Mapping[]

local Terminal = Object:extend() --@as chris468.util.Terminal

Terminal.mappings = {
  { "<C-H>", cmd("TmuxNavigateLeft"), desc = "Navigate left", mode = "t" },
  { "<C-J>", cmd("TmuxNavigateDown"), desc = "Navigate down", mode = "t" },
  { "<C-K>", cmd("TmuxNavigateUp"), desc = "Navigate up", mode = "t" },
  { "<C-L>", cmd("TmuxNavigateRight"), desc = "Navigate right", mode = "t" },
}

function Terminal.enable_mappings(bufnr)
  vim.b[bufnr].chris468_terminal_mappings = true
  for _, mapping in ipairs(Terminal.mappings) do
    vim.keymap.set(mapping.mode, mapping[1], mapping[2], {
      desc = mapping.desc,
      buffer = bufnr,
    })
  end
end

function Terminal.disable_mappings(bufnr)
  vim.b[bufnr].chris468_terminal_mappings = false
  for _, mapping in ipairs(Terminal.mappings) do
    vim.keymap.set(mapping.mode, mapping[1], mapping[1], {
      buffer = bufnr,
      remap = false,
    })
  end
end

function Terminal.toggle_mappings()
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].buftype ~= "terminal" then
    return
  end

  -- Previous state is enabled if nil or true, disabled if false
  -- New state is enabled if false, disabled if nil or true
  local enable = vim.b[bufnr].chris468_terminal_mappings == false
  if enable then
    Terminal.enable_mappings(bufnr)
  else
    Terminal.disable_mappings(bufnr)
  end
end

function Terminal.toggle(_)
  Terminal._abstract("toggle")
end

function Terminal._abstract(method)
  error("Method " .. method .. " is abstract")
end

return Terminal
