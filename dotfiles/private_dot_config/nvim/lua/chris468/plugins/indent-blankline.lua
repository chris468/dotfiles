return {
  "lukas-reineke/indent-blankline.nvim",
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },
  main = "ibl",
  opts = {
    indent = { char = "┊", highlight = "chris468.IndentGuide" },
    scope = { enabled = true, show_start = false, show_end = false, highlight = "chris468.ScopeGuide" },
  },
}
