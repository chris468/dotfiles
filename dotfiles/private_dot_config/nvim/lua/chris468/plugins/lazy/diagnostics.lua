return {
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "mini.icons" },
    opts = {
      follow = false,
      icons = {
        kinds = setmetatable({}, {
          __index = function(_, k)
            return require("mini.icons").get("lsp", k)
          end,
        }),
      },
      modes = {
        lsp_base = {
          focus = true,
          follow = false,
          auto_refresh = false,
        },
        diagnostics = {
          follow = true,
          auto_preview = false,
        },
        lsp_document_symbols = {
          auto_preview = false,
          format = "{kind_icon} {symbol.name} {pos}",
          win = {
            position = "right",
            size = 0.3,
          },
        },
      },
      win = {
        size = 10,
      },
      preview = {
        type = "float",
        scratch = true,
        size = { width = 0.8, height = 0.3 },
        anchor = "SW",
        border = "rounded",
        position = { -12, 0.5 },
      },
    },
  },
}
