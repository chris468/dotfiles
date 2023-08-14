-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function map_hide_highlight()
  vim.keymap.set("n", "<leader>h", "<cmd>noh<cr>", { desc = "No highlight" })
end

local function map_resume_search()
  vim.keymap.set("n", "<leader>r", "<cmd>Telescope resume<CR>", { desc = "Resume last search" })
end

local function map_dotfiles()
  vim.keymap.set("n", "<leader>Da", "<cmd>!chezmoi apply<CR>", { desc = "Apply dotfiles" })
  vim.keymap.set("n", "<leader>DA", "<cmd>!chezmoi add %<CR>", { desc = "Add current file to dotfiles" })
end

local function clear_line_movement()
  -- was accidentally triggering when leaving insert mode and trying to move
  vim.keymap.del({ "n", "i", "v" }, "<A-j>")
  vim.keymap.del({ "n", "i", "v" }, "<A-k>")
end

local function clear_terminals()
  -- replacing with toggleterm
  vim.keymap.del("n", "<leader>ft")
  vim.keymap.del("n", "<leader>fT")
  vim.keymap.del({ "n", "t" }, "<C-/>")
  vim.keymap.del({ "n", "t" }, "<C-_>")

  -- don't unmap <leader>gg because it is reconfigured in toggleterm plugin configuration
end

local function clear()
  clear_line_movement()
  clear_terminals()
end

local function map()
  map_hide_highlight()
  map_resume_search()
  map_dotfiles()
end

clear()
map()
