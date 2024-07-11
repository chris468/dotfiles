--- @class chris468.NordColors
--- @field [number]  { gui: string, cterm: string? }
local nord = {
  [0] = { gui = "#2E3440" },
  [1] = { gui = "#3B4252", cterm = "0" },
  [2] = { gui = "#434C5E" },
  [3] = { gui = "#4C566A", cterm = "8" },
  [4] = { gui = "#D8DEE9" },
  [5] = { gui = "#E5E9F0", cterm = "7" },
  [6] = { gui = "#ECEFF4", cterm = "15" },
  [7] = { gui = "#8FBCBB", cterm = "14" },
  [8] = { gui = "#88C0D0", cterm = "6" },
  [9] = { gui = "#81A1C1", cterm = "4" },
  [10] = { gui = "#5E81AC", cterm = "12" },
  [11] = { gui = "#BF616A", cterm = "1" },
  [12] = { gui = "#D08770", cterm = "11" },
  [13] = { gui = "#EBCB8B", cterm = "3" },
  [14] = { gui = "#A3BE8C", cterm = "2" },
  [15] = { gui = "#B48EAD", cterm = "5" },
}

--- @class chris468.NordTheme: chris468.Theme
--- @field colors chris468.NordColors

--- @type chris468.NordTheme
return {
  colors = nord,
  highlights = {
    IblIndent = { fg = nord[2].gui },
    IblScope = { fg = nord[0].gui },
    BreakpointLine = {
      bg = "#120708", -- nord[11] w/ lightness decreased to 5%
    },
    StoppedLine = {
      bg = "#231906", -- nord[13] w/ lightness decreased to 8%
    },
    StoppedIcon = { fg = nord[13].gui },
    DapBreakpoint = { fg = nord[11].gui },
    DapLogPoint = { fg = nord[8].gui },
  },
}
