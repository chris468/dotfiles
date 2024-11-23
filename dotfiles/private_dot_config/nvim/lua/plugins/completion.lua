return {
  "nvim-cmp",
  dependencies = { "chrisgrieser/cmp-nerdfont" },
  opts = function(_, opts)
    local cmp = require("cmp")

    table.insert(opts.sources, {
      name = "nerdfont",
      group_index = 1,
    })
    opts.window = vim.tbl_deep_extend("force", opts.window or {}, {
      completion = {
        border = "rounded",
        winhighlight = "FloatBorder:NoiceCmdlinePopupBorder",
      },
      documentation = {
        border = "rounded",
        winhighlight = "FloatBorder:NoiceCmdlinePopupBorder",
      },
    })
  end,
}
