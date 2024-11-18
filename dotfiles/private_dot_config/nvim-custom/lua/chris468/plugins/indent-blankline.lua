return {
  "lukas-reineke/indent-blankline.nvim",
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },
  main = "ibl",
  opts = {
    indent = { char = "┊" },
    scope = { enabled = true, show_start = false, show_end = false },
  },
}
