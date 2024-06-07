local theme = require("chris468.config.settings").theme
local is_default_theme = theme:find("^catppuccin") ~= nil

local priority = nil
if is_default_theme then
  priority = 1000
end

return {
  "catppuccin/nvim",
  init = function()
    local catppuccin = require("catppuccin.palettes").get_palette("mocha")

    local function create_highlights()
      vim.api.nvim_set_hl(0, "chris468.IndentGuide", {
        force = true,
        fg = catppuccin.surface0,
      })
      vim.api.nvim_set_hl(0, "chris468.ScopeGuide", {
        force = true,
        fg = catppuccin.lavender,
      })
    end

    if is_default_theme then
      create_highlights()
    end

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("catppuccin highlights", {}),
      pattern = "catppuccin*",
      callback = create_highlights,
    })
  end,
  config = function()
    if is_default_theme then
      vim.cmd("colorscheme " .. theme)
    end
  end,
  lazy = not is_default_theme,
  name = "catppuccin",
  priority = priority,
}
