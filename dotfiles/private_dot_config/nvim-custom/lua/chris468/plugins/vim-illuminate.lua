return {
  "RRethy/vim-illuminate",
  config = function(_, opts)
    require("illuminate").configure(opts)
  end,
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },
  opts = {},
}
