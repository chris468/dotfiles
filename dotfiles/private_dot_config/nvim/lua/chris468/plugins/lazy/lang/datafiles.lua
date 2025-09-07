return {
  {
    "chris468-tools",
    dependencies = { "b0o/schemastore.nvim", version = false },
    opts = function(_, opts)
      opts = opts or {}
      opts.lsps = opts.lsps or {}
      local lsps = opts.lsps
      lsps["json-lsp"] = {
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
      lsps.taplo = {}

      lsps["yaml-language-server"] = {
        lspconfig = {
          settings = {
            yaml = {
              format = {
                enable = true,
              },
            },
          },
        },
      }
    end,
  },
}
