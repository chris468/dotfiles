-- Esc followed by j/k were moving lines instead of navigating
vim.keymap.del({ "n", "i", "v" }, "<A-j>")
vim.keymap.del({ "n", "i", "v" }, "<A-k>")

-- I never increment on purpose
vim.keymap.set("n", "<C-a>", "<nop>")
