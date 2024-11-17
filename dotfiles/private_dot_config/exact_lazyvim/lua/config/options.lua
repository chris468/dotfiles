-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_picker = "telescope"
vim.g.trouble_lualine = false

_G.Chris468 = vim.tbl_deep_extend("error", {
  options = {
    use_toggleterm = false,
  },
}, require("config.chezmoi"))
