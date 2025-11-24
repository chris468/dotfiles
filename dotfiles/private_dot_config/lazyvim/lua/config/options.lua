vim.g.lazyvim_picker = "snacks"

---@type string|string[]
vim.g.chris468_ai_providers = {}
vim.g.ai_cmp = false

vim.opt.timeoutlen = 1000

require("config.chezmoi")

local found, err = pcall(require, "config.local")
if not found and not err:find("^module 'config.local' not found") then
  error(err)
end
