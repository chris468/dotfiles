-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.trouble_lualine = false

vim.g.root_spec = { "lsp", "*.sln", "*.csproj", { ".git", "lua" }, "cwd" }

local chezmoi = require("config.chezmoi")

---@class Chris468.Options.Lsp.FormattersForFiletype
---@field [integer] string? The formatters for the filetype
---@field _replace boolean? Whether to replace the default formatters for the filetype with these formatters
---@field _remove string[]? Remove the specified formatters from the defaults.

---@class Chris468.Options.Lsp
---@field ensure_installed string[] -- Install for the appropriate file type even if not registerd w/ lspconfig/conform/nvim-lint
---@field ensure_not_installed string[] -- Prevent mason packages from being installed.
---@field install lazy-mason-install.Config
---@field formatters table<string, Chris468.Options.Lsp.FormattersForFiletype>
---@field lspconfig table Roughly nvim-lspconfig settings, but see LazyVim's lsp config docs.

---@class Chris468.Options
---@field ai "None"|"Codeium"|"Copilot"|nil,
---@field lsp Chris468.Options.Lsp

local chris468 = {
  ---@type Chris468.Options
  options = {
    ai = chezmoi.options.work and "Copilot" or "Codeium",
    lsp = {
      ensure_installed = {
        "rust-analyzer", -- a plugin registers the lsp, not using lspconfig
        "lemminx", -- xml language server
        "xmlformatter",
      },
      ensure_not_installed = {
        "csharpier", -- opinionated towards non-standard style
      },
      install = {
        packages_for_filetypes = {
          ["ansible-lint"] = { "yaml.ansible" },
          ["java-debug-adapter"] = { "java" },
          ["java-test"] = { "java" },
          ["js-debug-adapter"] = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
          ["php-cs-fixer"] = { "php" },
          tflint = { "hcl", "terraform" },
          xmlformatter = { "xml" },
        },
        prerequisites = {
          ["nil"] = function()
            return vim.fn.executable("nix") == 1, "nix package manager"
          end,
        },
      },
      formatters = {
        cs = {
          _remove = {
            -- "csharpier",
          },
        },
      },
      lspconfig = {
        servers = {
          terraformls = {
            filetypes = { "tf", "terraform", "terraform-vars" },
          },
          bashls = {},
          yamlls = {
            settings = {
              yaml = {
                format = {
                  enable = false,
                },
              },
            },
          },
          azure_pipelines_ls = {
            enabled = false,
            settings = {
              yaml = {
                schemas = {
                  ["https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/master/service-schema.json"] = {
                    "*pipeline*.y*l",
                    "*Pipeline*.y*l",
                  },
                },
              },
            },
          },
        },
      },
    },
  },
}

if chezmoi.options.work then
  -- vim.list_extend(chris468.options.lsp.ensure_not_installed, { "markdownlint-cli2" })
  chris468.options.lsp.formatters.markdown = {
    _remove = { "markdownlint-cli2" },
  }
  chris468.options.lsp.formatters["markdown.mdx"] = chris468.options.lsp.formatters.markdown
end

local overrides = require("config.local")

_G.Chris468 = vim.tbl_deep_extend("error", vim.tbl_deep_extend("force", chris468, overrides), chezmoi)
