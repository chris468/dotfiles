local base16 = require("base16-colorscheme").colors

--- @type chris468.Theme
return {
  highlights = {
    IblIndent = { fg = base16.base05 },
    IblScope = { fg = base16.base05 },
    BreakpointLine = { bg = base16.base05 },
    StoppedLine = { bg = base16.base05 },
    StoppedIcon = { fg = base16.base05 },
  },
}
