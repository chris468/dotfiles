local base16 = require("base16-colorscheme").colors

--- @type chris468.Theme
local M = {
  highlights = {
    IblIndent = { fg = base16.base05 },
    IblScope = { fg = base16.base05 },
    BreakpointLine = { bg = base16.base05 },
    StoppedLine = { bg = base16.base05 },
    StoppedIcon = { fg = base16.base05 },
  },
}

function M.add_cterm(colors)
  return vim.tbl_extend("keep", colors, {
    cterm00 = 0,
    cterm01 = 8,
    cterm02 = 11,
    cterm03 = 10,
    cterm04 = 13,
    cterm05 = 14,
    cterm06 = 12,
    cterm07 = 5,
    cterm08 = 3,
    cterm09 = 8,
    cterm0A = 11,
    cterm0B = 10,
    cterm0C = 13,
    cterm0D = 14,
    cterm0E = 12,
    cterm0F = 7,
  })
end

return M
