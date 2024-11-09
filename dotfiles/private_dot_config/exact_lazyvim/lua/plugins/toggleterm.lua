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
      open_mapping = [[<c-\>]],
      float_opts = {
        border = "rounded",
        title_pos = "center",
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
