return {
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "mini.icons" },
    opts = function(_, opts)
      vim.notify(vim.inspect(opts))
      local icons = require("mini.icons")
      local strutil = require("chris468.string")
      local overrides = {
        focus = false,
        follow = false,
        open_no_results = true,
        warn_no_results = false,
        modes = {
          symbols = {
            follow = true,
          },
        },
        icons = {
          kinds = {},
        },
      }

      for _, kind in ipairs(icons.list("lsp")) do
        overrides.icons.kinds[strutil.capitalize(kind)] = icons.get("lsp", kind)
      end

      return vim.tbl_deep_extend("force", opts, overrides)
    end,
    version = "*",
  },
}
