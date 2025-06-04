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
  formatters = {
    bash = { "shfmt" },
    cs = { { "csharpier", install = false } },
    go = { "goimports", "gofumpt" },
    htmlangular = { "prettier" },
    lua = { "stylua" },
    markdown = { "prettier" },
    ["markdown.mdx"] = { "prettier" },
    php = { { "php_cs_fixer", package = "php-cs-fixer" } },
    python = { "black" },
    sh = { "shfmt" },
    terraform = { "terraform_fmt" },
    ["terraform-vars"] = { "terraform_fmt" },
    tf = { "terraform_fmt" },
    zsh = { "shfmt" },
  },
  ---@type chris468.config.ToolsByFiletype
  linters = {
    dockerfile = { "hadolint" },
    markdown = { "markdownlint-cli2" },
    ["markdown.mdx"] = { "markdownlint-cli2" },
    php = { "phpcs" },
    terraform = { "terraform_validate" },
    tf = { "terraform_validate" },
  },
  ---@type chris468.config.Lsps
  lsps = {
    angularls = {},
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
    marksman = {},
    nushell = {},
    omnisharp = {},
    phpactor = {},
    pyright = {},
    ruff = {},
    tailwindcss = {
      config = function()
        local filetypes = vim.tbl_get(vim.lsp.config, "tailwindcss", "filetypes")
        if filetypes then
          filetypes = vim.tbl_filter(function(ft)
            return ft ~= "markdown"
          end, vim.lsp.config.tailwindcss.filetypes or {})
        end
        return {
          filetypes = filetypes,
        }
      end,
    },
    terraformls = {
      filetypes = { "tf", "terraform", "terraform-vars" },
    },
    taplo = {},
    vtsls = {
      config = function()
        local mason_path = require("mason-core.installer.InstallLocation").global():get_dir()
        return {
          settings = {
            vstls = {
              tsserver = {
                globalPlugins = {
                  {
                    name = "@angular/language-server",
                    location = string.format(
                      "%s/packages/angular-language-server/node_modules/@angular/language-server",
                      mason_path
                    ),
                  },
                },
              },
            },
          },
        }
      end,
    },
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
