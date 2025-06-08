return {
  {
    "nvim-lspconfig",
    opts = function(_, opts)
      opts = opts or {}
      opts["angular-language-server"] = {}
      opts.phpactor = {}

      local tailwindcss_lsp_filetypes = vim.tbl_get(vim.lsp.config, "tailwindcss", "filetypes")
      opts["tailwindcss-language-server"] = {
        lspconfig = {
          filetypes = tailwindcss_lsp_filetypes and vim.tbl_filter(function(ft)
            return ft ~= "markdown"
          end, tailwindcss_lsp_filetypes) or nil,
        },
      }

      local mason_path = require("mason-core.installer.InstallLocation").global():get_dir()
      local angular_plugin = {
        name = "@angular/language-server",
        location = string.format(
          "%s/packages/angular-language-server/node_modules/@angular/language-server",
          mason_path
        ),
      }
      opts.vtsls = {
        lspconfig = {
          settings = {
            vstls = {
              tsserver = {
                globalPlugins = { angular_plugin },
              },
            },
          },
        },
      }

      return opts
    end,
  },
  {
    "conform.nvim",
    opts = {
      formatters_by_ft = {
        web = {
          htmlangular = { "prettier" },
          php = { { "php_cs_fixer", package = "php-cs-fixer" } },
        },
      },
    },
  },
  {
    "nvim-lint",
    opts = {
      linters_by_ft = {
        web = {
          php = { "phpcs" },
        },
      },
    },
  },
}
