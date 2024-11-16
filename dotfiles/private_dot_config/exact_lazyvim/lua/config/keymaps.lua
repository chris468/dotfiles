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
    remove = vim.g.chris468_use_toggleterm or false,
    modes = "n",
    keys = { "<leader>ft", "<leader>fT" },
  },
}
for _, spec in ipairs(remove_keymaps) do
  local remove = spec.remove == nil or spec.remove
  if remove then
    local keys = type(spec.keys) == "table" and spec.keys or {
      spec.keys --[[@as string]],
    }
    for _, key in ipairs(keys) do
      vim.keymap.del(spec.modes, key)
    end
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

if vim.g.chris468_use_toggleterm then
  local terminal_specs = require("chris468.terminal.specs")
  vim.keymap.set("n", "<leader>ftt", terminal_specs.float, { desc = "Float terminal" })
  vim.keymap.set("n", "<leader>fth", terminal_specs.horizontal, { desc = "Horizontal terminal" })
  vim.keymap.set("n", "<leader>ftv", terminal_specs.vertical, { desc = "Vertical terminal" })
  vim.keymap.set("n", "<leader>fda", terminal_specs.chezmoi_apply, { desc = "Apply chezmoi dotfiles" })
  vim.keymap.set("n", "<leader>fdA", terminal_specs.chezmoi_add, { desc = "Add current file to dotfiles" })
  vim.keymap.set("n", "<leader>ftb", "<cmd>TermSelect<cr>", { desc = "Browse" })
else
  ---@param cmd? string | string[] | fun() : (string|string[])
  ---@param opts? snacks.terminal.Opts
  ---@return fun()
  local function terminal(cmd, opts)
    return function()
      if type(cmd) == "function" then
        cmd = cmd()
      end
      Snacks.terminal(cmd, opts)
    end
  end
  vim.keymap.set("n", "<leader>fda", terminal("chezmoi apply", { win = { position = "bottom" } }))
  vim.keymap.set(
    "n",
    "<leader>fdA",
    terminal(function()
      return { "chezmoi", "add", vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()) }
    end, { win = { position = "bottom" } })
  )
end

if lazyvim.util.has("nvim-luapad") then
  vim.keymap.set("n", "<leader>cL", function()
    require("chris468.luapad").toggle()
  end, { desc = "LuaPad" })
end
