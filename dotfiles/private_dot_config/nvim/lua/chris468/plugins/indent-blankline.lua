return {
  "lukas-reineke/indent-blankline.nvim",
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },
  init = function()
    local util = require("chris468.util")
    local nord = require("chris468.nord-colors")

    util.regisiter_highlights("chris468IndentHighlights", {
      ["chris468.IndentGuide"] = {
        force = true,
        guifg = nord[2].gui,
        ctermfg = nord[2].cterm,
      },
      ["chris468.ScopeGuide"] = {
        force = true,
        guifg = nord[9].gui,
        ctermfg = nord[9].cterm,
      },
    })
  end,
  main = "ibl",
  opts = {
    indent = { char = "┊", highlight = "chris468.IndentGuide" },
    scope = { enabled = true, show_start = false, show_end = false, highlight = "chris468.ScopeGuide" },
  },
}
