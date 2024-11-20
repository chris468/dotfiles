return {
  "nvim-cmp",
  dependencies = { "chrisgrieser/cmp-nerdfont" },
  opts = function(_, opts)
    table.insert(opts.sources, {
      name = "nerdfont",
      group_index = 1,
    })
  end,
}
