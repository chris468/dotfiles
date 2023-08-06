vim.keymap.set("n", "<leader>h", "<cmd>noh<cr>", { desc = "No highlight" })
vim.keymap.del({ "n", "i", "v" }, "<A-j>")
vim.keymap.del({ "n", "i", "v" }, "<A-k>")

# load here to be sure it overwrites the LazyVim keymaps
vim.cmd("Lazy load vim-tmux-navigator")
