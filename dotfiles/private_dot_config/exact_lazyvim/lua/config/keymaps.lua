-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- was accidentally triggering line movement when leaving insert mode and trying to move
vim.keymap.del({ "n", "i", "v" }, "<A-j>")
vim.keymap.del({ "n", "i", "v" }, "<A-k>")

-- I never increment on purpose
vim.keymap.set("n", "<C-a>", "<nop>")

-- chezmoi dotfiles
vim.keymap.set("n", "<leader>Da", "<cmd>!chezmoi apply<CR>", { desc = "Apply dotfiles" })
vim.keymap.set("n", "<leader>DA", "<cmd>!chezmoi add %<CR>", { desc = "Add current file to dotfiles" })
