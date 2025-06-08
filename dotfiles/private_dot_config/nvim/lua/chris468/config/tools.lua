--[[ TODO:
    java
    ~~nix~~
    rust
    sql

also:
  test
  dap
]]

local chezmoi = require("chris468.config.chezmoi")

return {
  ---@type string[] disable tooling on these filetypes
  disable_filetypes = { "lazy", "lazy_backdrop", "mason", "oil" },
  ---@type { provider: "codeium"|"copilot" }
  ai = {
    provider = chezmoi.work and "copilot" or "codeium",
  },
  ---@type chris468.config.FormattersByFiletype
  ---@type chris468.config.ToolsByFiletype
  linters = {
    dockerfile = { "hadolint" },
  },
  ---@type chris468.config.Lsps
  lsps = {
    clangd = {},
    dockerls = {},
    docker_compose_language_service = {},
    helm_ls = {},
    jsonls = {
      config = function()
        return {
          settings = {
            json = {
              format = { enable = true },
              validate = { enable = true },
              schemas = require("schemastore").json.schemas(),
            },
          },
        }
      end,
    },
    nushell = {},
    taplo = {},
    yamlls = {
      config = {
        settings = {
          yaml = {
            format = {
              enable = false,
            },
          },
        },
      },
    },
  },
}
