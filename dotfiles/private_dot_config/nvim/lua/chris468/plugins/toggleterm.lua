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
    { "<C-\\>" },
    { "<leader>ft", "<cmd>TermSelect<CR>", desc = { "Terminal" } },
  },
  opts = {
    open_mapping = "<C-\\>",
    direction = "float",
    float_opts = {
      border = "rounded",
    },
  },
}
