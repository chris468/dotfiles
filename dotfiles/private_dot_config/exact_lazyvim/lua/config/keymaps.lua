-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local lazyvim = {
  util = require("lazyvim.util"),
}

-- was accidentally triggering line movement when leaving insert mode and trying to move
vim.keymap.del({ "n", "i", "v" }, "<A-j>")
vim.keymap.del({ "n", "i", "v" }, "<A-k>")

-- I never increment on purpose
vim.keymap.set("n", "<C-a>", "<nop>")

vim.keymap.set("n", "<leader>f<C-T>", "<cmd>TermSelect<cr>", { desc = "Terminals" })

lazyvim.util.on_load("which-key.nvim", function()
  local wk = require("which-key")
  wk.add({
    { "<leader>fd", group = "Chezmoi Dotfiles" },
  })
end)

vim.keymap.set("n", "<leader>fda", "", {
  desc = "Apply chezmoi dotfiles",
  callback = function()
    require("chris468.terminal").open(
      "chezmoi apply",
      { direction = "horizontal", display_name = "Chezmoi", remain_on_error = true, warn_on_unsaved = true }
    )
  end,
})
vim.keymap.set("n", "<leader>fdA", "", {
  desc = "Add current file to dotfiles",
  callback = function()
    local cmd = function()
      return { "chezmoi", "add", vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()) }
    end
    require("chris468.terminal").open(
      cmd,
      { direction = "horizontal", display_name = "Chezmoi", remain_on_error = true, warn_on_unsaved = true }
    )
  end,
})
