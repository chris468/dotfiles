local function size(term)
  if term.direction == "horizontal" then
    return vim.o.lines * 0.25
  elseif term.direction == "vertical" then
    return vim.o.columns * 0.4
  end
end

local function default(direction)
  local function toggle()
    local tt = require("toggleterm")
    tt.toggle(1, nil, nil, direction, "Terminal")
  end

  return toggle
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
    },
    size = size,
  },
}
