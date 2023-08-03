vim.keymap.set("n", "<leader>h", "<cmd>noh<cr>", { desc = "No highlight" })
vim.keymap.del({ "n", "i", "v" }, "<A-j>")
vim.keymap.del({ "n", "i", "v" }, "<A-k>")
