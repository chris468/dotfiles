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
  opts = function()
    return {
      direction = "float",
      open_mapping = nil, -- handled by chris468.terminal
      float_opts = {
        border = { "", "─", "", "", "", "", "", "" },
        title_pos = "center",
        width = function()
          return vim.o.columns
        end,
        height = function()
          return vim.o.lines - 1
        end,
      },
      size = function(term)
        if term.direction == "horizontal" then
          return vim.o.lines * 0.25
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
    }
  end,
}
