local themes = require("chris468.themes")
themes.configure_highlights(vim.g.colors_name)

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("chris468.theme", {}),
  callback = function(arg)
    local colorscheme = arg.match
    themes.configure_highlights(colorscheme)
  end,
})
