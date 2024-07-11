local catppuccin = require("catppuccin.palettes").get_palette("mocha")

--- @type chris468.Theme
return {
  highlights = {
    IblIndent = { fg = catppuccin.surface0 },
    IblScope = { fg = catppuccin.lavender },
    BreakpointLine = {
      bg = "#170208", -- catppuccin.red w/ lightness decreased to 5%
    },
    StoppedLine = {
      bg = "#261b03", -- catppuccin.yellow w/ lightness decreased to 8%
    },
    StoppedIcon = { fg = catppuccin.yellow },
  },
}
