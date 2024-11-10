-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local lazyvim = {
  util = require("lazyvim.util"),
}

---@class remove_keymap
---@field modes string|string[]
---@field keys string|string[]

local remove_keymaps = {
  {
    -- was accidentally triggering line movement when leaving insert mode and trying to move
    modes = { "n", "i", "v" },
    keys = { "<A-j>", "<A-k>" },
  },
  {
    -- will make a submenu under <leader>ft for terminals
    modes = "n",
    keys = { "<leader>ft", "<leader>fT" },
  },
}
for _, remove in ipairs(remove_keymaps) do
  local keys = type(remove.keys) == "table" and remove.keys or {
    remove.keys --[[@as string]],
  }
  for _, key in ipairs(keys) do
    vim.keymap.del(remove.modes, key)
  end
end

-- I never increment on purpose
vim.keymap.set("n", "<C-a>", "<nop>")

lazyvim.util.on_load("which-key.nvim", function()
  local wk = require("which-key")
  wk.add({
    { "<leader>fd", group = "Chezmoi Dotfiles" },
    { "<leader>ft", group = "Terminals" },
  })
end)

local terminals = require("config.terminals")
vim.keymap.set("n", "<leader>ftt", "", {
  desc = "Float terminal",
  callback = terminals.float,
})
vim.keymap.set("n", "<leader>fth", "", {
  desc = "Horizontal terminal",
  callback = terminals.horizontal,
})
vim.keymap.set("n", "<leader>ftv", "", {
  desc = "Vertical terminal",
  callback = terminals.vertical,
})
vim.keymap.set("n", "<leader>fda", "", {
  desc = "Apply chezmoi dotfiles",
  callback = terminals.chezmoi_apply,
})
vim.keymap.set("n", "<leader>fdA", "", {
  desc = "Add current file to dotfiles",
  callback = terminals.chezmoi_add,
})
vim.keymap.set("n", "<leader>ftb", "<cmd>TermSelect<cr>", { desc = "Browse" })
