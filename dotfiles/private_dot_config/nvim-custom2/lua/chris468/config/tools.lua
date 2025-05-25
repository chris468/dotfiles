local chezmoi = require("chris468.config.chezmoi")

return {
  ---@type string[] disable tooling on these filetypes
  disable = { "lazy", "lazy_backdrop", "mason" },
  ---@type { provider: "codeium"|"copilot" }
  ai = {
    provider = chezmoi.work and "copilot" or "codeium",
  },
  ---@type chris468.config.FormattersByFiletype
  formatters = {
    cs = { { "csharpier", install = false } },
    htmlangular = { "prettier" },
    lua = { "stylua" },
    python = { "black" },
  },
  ---@type chris468.config.ToolsByFiletype
  linters = {
    ["yaml.ansible"] = { "ansible-lint" },
    markdown = { "markdownlint-cli2" },
  },
  ---@type chris468.config.Lsps
  lsps = {
    angular_ls = {},
    lua_ls = {
      config = {
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
            hint = {
              enable = true,
              setType = false,
              paramType = true,
              paramName = "Disable",
              semicolon = "Disable",
              arrayIndex = "Disable",
            },
          },
        },
      },
    },
    omnisharp = {},
    pyright = {},
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
