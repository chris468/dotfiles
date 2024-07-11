local themes = require("chris468.themes")
local theme = require("chris468.config.settings").theme
local is_default_theme = themes.family(theme) == "base16"

local priority = nil
if is_default_theme then
  priority = 1000
end

return {
  "RRethy/base16-nvim",
  config = function()
    if is_default_theme then
      vim.cmd("colorscheme " .. theme)
    end
  end,
  lazy = not is_default_theme,
  main = "base16-colorscheme",
  priority = priority,
}
