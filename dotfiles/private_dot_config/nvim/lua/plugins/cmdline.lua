return {
  {
    "folke/noice.nvim",
    opts = {
      presets = {
        command_palette = false,
        inc_rename = false,
      },
      cmdline = {
        view = "cmdline",
      },
    },
  },
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

      vim.api.nvim_create_autocmd("CmdwinEnter", {
        group = vim.api.nvim_create_augroup("Close cmp", { clear = true }),
        callback = function()
          cmp.close()
        end,
      })
    end,
  },
}
