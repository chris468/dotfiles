return {
  "nordtheme/vim",
  config = function()
    vim.cmd([[colorscheme nord]])
  end,
  lazy = false,
  init = function()
    vim.g.nord_cursor_line_number_background = 1
  end,
  name = "nord",
  priority = 1000,
}
