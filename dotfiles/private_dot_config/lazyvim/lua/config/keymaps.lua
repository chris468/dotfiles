-- Esc followed by j/k were moving lines instead of navigating
vim.keymap.del({ "n", "i", "v" }, "<A-j>")
vim.keymap.del({ "n", "i", "v" }, "<A-k>")

-- I never increment on purpose
vim.keymap.set("n", "<C-a>", "<nop>")

-- Default keymaps I don't, remapm or use for something else
vim.keymap.del("n", "<leader>l") -- Lazy

vim.keymap.set("n", "<leader>za", function()
  require("util.chezmoi").apply("all")
end, { desc = "Apply" })

vim.keymap.set("n", "<leader>zd", function()
  require("util.chezmoi").apply("current_dir")
end, { desc = "Apply current source dir" })

vim.keymap.set("n", "<leader>zf", function()
  require("util.chezmoi").apply("current_file")
end, { desc = "Apply current source file" })

vim.keymap.set("n", "<leader>zu", function()
  require("util.chezmoi").update(false)
end, { desc = "Update" })

vim.keymap.set("n", "<leader>zU", function()
  require("util.chezmoi").update(true)
end, { desc = "Update and apply" })

vim.keymap.set("n", "<leader>pl", "<cmd>Lazy<CR>", { desc = "Lazy" })
vim.keymap.set("n", "<leader>pL", function()
  LazyVim.news.changelog()
end, { desc = "LazyVim changelog" })
vim.keymap.set("n", "<leader>px", "<cmd>LazyExtras<CR>", { desc = "LazyVim extras" })
vim.keymap.set("n", "<leader>pm", "<cmd>Mason<CR>", { desc = "Mason" })

---@module 'lazyvim'
LazyVim.on_load("which-key.nvim", function()
  require("which-key").add({
    { "<leader>z", group = "Chezmoi" },
    { "<leader>p", group = "Packages" },
    { "<leader>l", group = "Lua" },
  })
end)
