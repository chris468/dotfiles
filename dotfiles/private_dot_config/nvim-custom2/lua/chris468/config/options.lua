vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.o.timeout = true
vim.o.timeoutlen = 250

local chezmoi = require("chris468.config.chezmoi")
local chris468 = {
  keymaps = {
    { "<leader>l", "<cmd>Lazy<CR>", desc = "Lazy", icon = "󰒲" },
  },
}
local has_overrides, overrides = pcall(require, "chris468.config.local")

_G.Chris468 =
  vim.tbl_deep_extend("error", vim.tbl_deep_extend("force", chris468, has_overrides and overrides or {}), chezmoi)
