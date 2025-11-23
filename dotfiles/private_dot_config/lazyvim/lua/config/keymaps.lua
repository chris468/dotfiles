do -- defaults I don't want
  -- Esc followed by j/k were moving lines instead of navigating
  vim.keymap.del({ "n", "i", "v" }, "<A-j>")
  vim.keymap.del({ "n", "i", "v" }, "<A-k>")

  -- I never increment on purpose
  vim.keymap.set("n", "<C-a>", "<nop>")

  vim.keymap.del("n", "<leader>l") -- Lazy
end

do -- chezmoi
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
end

do -- package management
  vim.keymap.set("n", "<leader>pl", "<cmd>Lazy<CR>", { desc = "Lazy" })
  vim.keymap.set("n", "<leader>pL", function()
    LazyVim.news.changelog()
  end, { desc = "LazyVim changelog" })
  vim.keymap.set("n", "<leader>px", "<cmd>LazyExtras<CR>", { desc = "LazyVim extras" })
  vim.keymap.set("n", "<leader>pm", "<cmd>Mason<CR>", { desc = "Mason" })
end

do -- telescope
  -- <leader>sl is the default for loclist, but I want it for lazy
  vim.keymap.set("n", "<leader>sL", "<cmd>Telescope loclist<cr>", { desc = "Location List" })
  vim.keymap.set("n", "<leader>sl", "<cmd>Telescope lazy<CR>", { desc = "Lazy" })
end

do -- tabs
  vim.keymap.set("n", "[<Tab>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
  vim.keymap.set("n", "]<Tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
end

-- group names / icons
---@module 'lazyvim'
LazyVim.on_load("which-key.nvim", function()
  require("which-key").add({
    { "<leader>z", group = "Chezmoi" },
    { "<leader>p", group = "Packages" },
    { "<leader>l", group = "Lua" },
  })
end)
