-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_picker = "snacks"

vim.g.trouble_lualine = false

vim.g.root_spec = { "lsp", "*.sln", "*.csproj", { ".git", "lua" }, "cwd" }

local chezmoi = require("config.chezmoi")

---@class Chris468Options
---@field options {
---   ai: "None"|"Codeium"|"Copilot"|nil,
---}
local chris468 = {
  options = {
    ai = chezmoi.options.work and "Copilot" or "Codeium",
  },
}
local overrides = require("config.local")

_G.Chris468 = vim.tbl_deep_extend("error", vim.tbl_deep_extend("force", chris468, overrides), chezmoi)
