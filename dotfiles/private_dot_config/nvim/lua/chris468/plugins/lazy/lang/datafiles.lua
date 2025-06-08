return {
  {
    "nvim-lspconfig",
    dependencies = { "b0o/schemastore.nvim", version = false },
    opts = function(_, opts)
      opts = opts or {}
      opts["json-lsp"] = {
        lspconfig = {
          settings = {
            json = {
              format = { enable = true },
              validate = { enable = true },
              schemas = require("schemastore").json.schemas(),
            },
          },
        },
      }

      -- toml
      opts.taplo = {}

      opts["yaml-language-server"] = {
        lspconfig = {
          settings = {
            yaml = {
              format = {
                enable = false,
              },
            },
          },
        },
      }
    end,
  },
}
