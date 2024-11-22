return {
  {
    "hrsh7th/cmp-cmdline",
    dependencies = { "dmitmel/cmp-cmdline-history" },
    event = "CmdlineEnter",
    config = function()
      local cmp = require("cmp")

      cmp.setup.cmdline(":", {
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
          { name = "cmdline_history" },
        }),
        matching = { disallow_symbol_nonprefix_matching = false },
        mapping = cmp.mapping.preset.cmdline(),
      })

      cmp.setup.cmdline({ "/", "?" }, {
        sources = {
          { name = "buffer" },
          { name = "cmdline_history", opts = { history_type = "/" } },
        },
        mapping = cmp.mapping.preset.cmdline(),
      })
    end,
  },
}
