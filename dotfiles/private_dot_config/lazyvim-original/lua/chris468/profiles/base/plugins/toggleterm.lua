local function create_terminal(opts)
  local Terminal = require("toggleterm.terminal").Terminal
  return Terminal:new(opts)
end

local function map_keys(map_normal)
  map_normal = map_normal == nil or map_normal
  local function unmap_window_navigation(bufnr)
    for _, key in pairs({ "<C-h>", "<C-j>", "<C-k>", "<C-l>" }) do
      vim.keymap.set({ "n", "i", "t" }, key, key, { buffer = bufnr })
    end
  end

  local function unmap_normal(bufnr)
    vim.keymap.set({ "n", "i", "t" }, "<Esc>", "<Esc>", { buffer = bufnr, nowait = true })
  end

  return function(terminal)
    if terminal.direction == "float" then
      unmap_window_navigation(terminal.bufnr)
    end

    if not map_normal then
      unmap_normal(terminal.bufnr)
    end
  end
end

local function horizontal()
  return create_terminal({
    count = 2,
    direction = "horizontal",
  })
end

local function lazygit()
  return create_terminal({
    hidden = true,
    direction = "float",
    cmd = "lazygit",
    on_create = map_keys(false),
  })
end

local function chezmoi()
  return create_terminal({
    count = 3,
    cmd = "chezmoi cd",
    direction = "float",
  })
end

return {
  "akinsho/toggleterm.nvim",
  opts = {
    open_mapping = "<C-\\>",
    direction = "float",
    float_opts = {
      border = "rounded",
    },
    on_create = map_keys(),
  },
  -- stylua: ignore
  keys = {
    { "<C-\\>" },
    { "<leader>ft", "<cmd>TermSelect<CR>", desc = "Terminal" },
    { "<leader>Tf", "<cmd>1ToggleTerm<cr>", mode = { "n", "t" }, desc = "Floating terminal" },
    { "<leader>Tt", function() horizontal():toggle() end, mode = { "n", "t" }, desc = "Horizontal terminal" },
    { "<leader>Td", function() chezmoi():toggle() end, mode = { "n", "t" }, desc = "Dotfiles" },
    { "<leader>gg", function() lazygit():toggle() end, mode = { "n", "t" }, desc = "Git" },
  },
  -- stylua: ignore end
  cmd = {
    "ToggleTerm",
    "ToggleTermToggleAll",
    "TermExec",
    "TermSelect",
    "ToggleTermSendCurrentLine",
    "ToggleTermSendVisualLines",
    "ToggleTermSendVisualSelection",
    "ToggleTermSetName",
  },
}
