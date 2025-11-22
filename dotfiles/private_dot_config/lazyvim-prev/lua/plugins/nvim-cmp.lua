return {
  {
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
  },
  {
    "hrsh7th/cmp-cmdline",
    dependencies = { "dmitmel/cmp-cmdline-history", "nvim-cmp" },
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
    optional = true,
  },
}
