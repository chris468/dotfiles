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
      vim.api.nvim_set_hl(0, "IblIndent", {
        force = true,
        fg = catppuccin.surface0,
      })
      vim.api.nvim_set_hl(0, "IblScope", {
        force = true,
        fg = catppuccin.lavender,
      })
      vim.api.nvim_set_hl(0, "BreakpointLine", {
        force = true,
        bg = "#170208", -- catppuccin.red w/ lightness decreased to 5%
      })
      vim.api.nvim_set_hl(0, "StoppedLine", {
        force = true,
        bg = "#261b03", -- catppuccin.yellow w/ lightness decreased to 8%
      })
      vim.api.nvim_set_hl(0, "StoppedIcon", {
        force = true,
        fg = catppuccin.yellow,
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
