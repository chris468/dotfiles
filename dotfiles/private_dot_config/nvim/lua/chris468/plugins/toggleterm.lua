local id = {
  default = 1,
}

local function size(term)
  if term.direction == "horizontal" then
    return vim.o.lines * 0.25
  elseif term.direction == "vertical" then
    return vim.o.columns * 0.4
  end
end

local function default(direction)
  local function toggle()
    local Terminal = require("toggleterm.terminal").Terminal
    local term = Terminal:new({
      id = id.default,
      display_name = "Terminal",
    })
    term:toggle(nil, direction)
  end

  return toggle
end

local function on_open(term)
  local has_tmux_navigation = vim.fn.exists(":TmuxNavigateLeft") ~= 0
  if has_tmux_navigation then
    local keys = {
      ["<esc><C-h>"] = "<cmd>TmuxNavigateLeft<cr>",
      ["<esc><C-j>"] = "<cmd>TmuxNavigateDown<cr>",
      ["<esc><C-k>"] = "<cmd>TmuxNavigateUp<cr>",
      ["<esc><C-l>"] = "<cmd>TmuxNavigateRight<cr>",
    }

    if term:is_split() then
      for key, cmd in pairs(keys) do
        vim.api.nvim_buf_set_keymap(term.bufnr, "t", key, cmd, {})
      end
    else
      for key, _ in pairs(keys) do
        pcall(vim.api.nvim_buf_del_keymap, term.bufnr, "t", key)
      end
    end
  end
end

return {
  "akinsho/toggleterm.nvim",
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
  keys = {
    { "<C-\\>", default(), mode = { "n", "t" }, desc = "Toggle terminal" },
    { "<leader>ft", "<cmd>TermSelect<CR>", desc = "Terminal" },
    { "<leader>mf", default("float"), desc = "Float" },
    { "<leader>mh", default("horizontal"), desc = "Horizontal" },
    { "<leader>mm", default(), desc = "Toggle" },
    { "<leader>mv", default("vertical"), desc = "Vertical" },
    { "<esc><esc>", "<C-\\><C-N>", mode = "t", desc = "Normal mode" },
  },
  opts = {
    direction = "float",
    float_opts = {
      border = "rounded",
      title_pos = "center",
    },
    on_open = on_open,
    size = size,
  },
}
