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
  })
end)

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
vim.keymap.set(
  "n",
  "<leader>fda",
  terminal("chezmoi apply", { win = { position = "bottom", wo = { winbar = "Apply chezmoi dotfiles" } } }),
  { desc = "Apply chezmoi dotfiles" }
)
vim.keymap.set(
  "n",
  "<leader>fdA",
  terminal(function()
    return { "chezmoi", "add", vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()) }
  end, { win = { position = "bottom" }, wo = { winbar = "Add current file to dotfiles" } }),
  { desc = "Add current file to dotfiles" }
)

if lazyvim.util.has("nvim-luapad") then
  vim.keymap.set("n", "<leader><c-l>", function()
    require("chris468.luapad").toggle()
  end, { desc = "LuaPad" })
end

if lazyvim.util.has("telescope.nvim") then
  local t = require("chris468.telescope")
  vim.keymap.set("n", "<leader>fr", LazyVim.pick("oldfiles", t.opts.ignore_helpdirs()), { desc = "Recent" })
  vim.keymap.set(
    "n",
    "<leader>fR",
    LazyVim.pick("oldfiles", t.opts.ignore_helpdirs({ cwd = vim.uv.cwd() })),
    { desc = "Recent (cwd)" }
  )
end

vim.keymap.set("n", "<leader>r", "<leader>sR", { desc = "Resume", remap = true })

if lazyvim.util.has("vim-tmux-navigator") then
  vim.keymap.set("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", { desc = "Move to window on left" })
  vim.keymap.set("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", { desc = "Move to window below" })
  vim.keymap.set("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", { desc = "Move to window above" })
  vim.keymap.set("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", { desc = "Move to window on right" })
end

local function F(n)
  return "F" .. n
end

local function Shift(k)
  return "S-" .. k
end

local function Control(k)
  return "C-" .. k
end

local function Wrap(k)
  return "<" .. k .. ">"
end

for k = 1, 12 do
  -- s-f10: <F22>
  -- c-f10: <F34>
  -- c-s-f10: <F46>

  vim.api.nvim_set_keymap("", Wrap(F(k + 12)), Wrap(Shift(F(k))), { desc = "which_key_ignore" })
  vim.api.nvim_set_keymap("", Wrap(F(k + 24)), Wrap(Control(F(k))), { desc = "which_key_ignore" })
  vim.api.nvim_set_keymap("", Wrap(F(k + 36)), Wrap(Control(Shift(F(k)))), { desc = "which_key_ignore" })
end

-- Prevent `<leader>cl` from being interpreted as `cl` when no lsp is attached.
-- It will be replaced when an lsp is attached.
vim.keymap.set(
  "n",
  "<leader>cl",
  vim.schedule_wrap(function()
    vim.notify("No lsp attached")
  end),
  { desc = "Lsp Info" }
)

local lazygit_mapping = Chris468.options.git.primary == "lazygit" and "<leader>gg" or "<leader>gG"
local neogit_mapping = Chris468.options.git.primary == "neogit" and "<leader>gg" or "<leader>gG"
vim.keymap.set("n", lazygit_mapping, function()
  Snacks.lazygit({ cwd = LazyVim.root.git() })
end, { desc = "Lazygit (Root Dir)" })
vim.keymap.set("n", neogit_mapping, "<cmd>Neogit<cr>", { desc = "Neogit" })
