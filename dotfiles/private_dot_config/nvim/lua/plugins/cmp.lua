return {
  "nvim-cmp",
  event = "CmdlineEnter",
  opts = function(_, opts)
    local cmp = require("cmp")
    local mapping = opts.mapping
    mapping["<C-k>"] = cmp.mapping(opts.mapping["<C-P>"], { "i", "c" })
    mapping["<C-j>"] = cmp.mapping(opts.mapping["<C-N>"], { "i", "c" })
  end,
}
