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
    local nord = require("chris468.nord-colors")
    vim.g.nord_cursor_line_number_background = 1

    local function create_highlights()
      vim.api.nvim_set_hl(0, "chris468.IndentGuide", {
        force = true,
        fg = nord[2].gui,
      })
      vim.api.nvim_set_hl(0, "chris468.ScopeGuide", {
        force = true,
        fg = nord[9].gui,
      })
      vim.api.nvim_set_hl(0, "chris468.BreakpointLine", {
        force = true,
        bg = "#120708", -- nord[11] w/ lightness decreased to 5%
      })
      vim.api.nvim_set_hl(0, "chris468.StoppedLine", {
        force = true,
        bg = "#231906", -- nord[13] w/ lightness decreased to 8%
      })
      vim.api.nvim_set_hl(0, "chris468.StoppedIcon", {
        force = true,
        fg = nord[13].gui,
      })
    end

    if is_default_theme then
      create_highlights()
    end

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("nord highlights", {}),
      pattern = "nord",
      callback = create_highlights,
    })
  end,
  lazy = not is_default_theme,
  name = "nord",
  priority = priority,
}
