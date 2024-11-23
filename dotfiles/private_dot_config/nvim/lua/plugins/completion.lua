return {
  "nvim-cmp",
  dependencies = {
    "chrisgrieser/cmp-nerdfont",
    "plenary.nvim",
  },
  opts = function(_, opts)
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

    local original_format = opts.formatting.format
    opts.formatting.format = function(entry, item)
      item = original_format(entry, item)
      item = require("chris468.cmp").format(entry, item)
      return item
    end
  end,
}
