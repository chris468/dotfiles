local opts = { noremap = true, silent = true }

vim.keymap.set("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<leader>h", vim.cmd.tabprevious, opts)
vim.keymap.set("n", "<leader>l", vim.cmd.tabnext, opts)
vim.keymap.set("n", "<leader>n", vim.cmd.nohlsearch, opts)

if require 'extensions.nvim-tree' then
  nvim_tree = require('nvim-tree.api')
  vim.keymap.set("n", "<leader>ef", nvim_tree.tree.open, opts)
  vim.keymap.set("n", "<leader>eF", function() nvim_tree.tree.open({find_file = true}) end, opts)
  vim.keymap.set("n", "<leader>et", nvim_tree.tree.toggle, opts)
end
