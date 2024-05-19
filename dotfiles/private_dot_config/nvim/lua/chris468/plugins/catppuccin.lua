local theme = require("chris468.config.settings").theme
local is_default_theme = theme:find("^catppuccin") ~= nil

local priority = nil
if is_default_theme then
  priority = 1000
end

return {
  "catppuccin/nvim",
  config = function()
    if is_default_theme then
      vim.cmd("colorscheme " .. theme)
    end
  end,
  lazy = not is_default_theme,
  name = "catppuccin",
  priority = priority,
}
