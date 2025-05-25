--[[ TODO:
    dotfiles
    java
    json
    markdown
    ~~nix~~
    nushell
    omnisharp
    php
    python
    rust
    sql
    tailwind - ??
    terraform
    toml
    typescript - require angular config?
    yaml

also:
  test
  dap
]]

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
    bash = { "shfmt" },
    cs = { { "csharpier", install = false } },
    go = { "goimports", "gofumpt" },
    htmlangular = { "prettier" },
    lua = { "stylua" },
    python = { "black" },
    sh = { "shfmt" },
    zsh = { "shfmt" },
  },
  ---@type chris468.config.ToolsByFiletype
  linters = {
    dockerfile = { "hadolint" },
    markdown = { "markdownlint-cli2" },
  },
  ---@type chris468.config.Lsps
  lsps = {
    angular_ls = {},
    ansiblels = {},
    bashls = {
      config = {
        filetypes = { "bash", "sh", "zsh" },
      },
    },
    clangd = {},
    dockerls = {},
    docker_compose_language_service = {},
    gopls = {},
    helm_ls = {},
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
