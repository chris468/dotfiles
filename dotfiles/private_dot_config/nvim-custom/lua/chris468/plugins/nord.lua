local theme = require("chris468.config.settings").theme
local is_default_theme = theme == "nord"

local priority = nil
if is_default_theme then
  priority = 1000
end

return {
  "nordtheme/vim",
  config = function()
    if is_default_theme then
      vim.cmd([[colorscheme nord]])
    end
  end,
  init = function()
    vim.g.nord_cursor_line_number_background = 1
  end,
  lazy = not is_default_theme,
  name = "nord",
  priority = priority,
  version = false,
}
