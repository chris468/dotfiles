local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

if require 'extensions.nvim-tree' then
  nvim_tree = require('nvim-tree.api')
  keymap("n", "<leader>ef", ":NvimTreeFocus<CR>", opts)
  keymap("n", "<leader>eF", ":NvimTreeFindFile<CR>", opts)
  keymap("n", "<leader>et", ":NvimTreeToggle<CR>", opts)
end
