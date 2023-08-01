vim.g.mapleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.o.swapfile = false
vim.o.backup = false

vim.o.number = true
vim.o.relativenumber = true

vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.autoindent = true
vim.o.wrap = false
vim.o.signcolumn = "yes"
vim.o.pumheight = 10

require("chris468.load-plugins")
