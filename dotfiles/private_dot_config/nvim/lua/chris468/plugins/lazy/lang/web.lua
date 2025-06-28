return {
  {
    "chris468-tools",
    opts = {
      lsps = {
        ["angular-language-server"] = {},
        phpactor = {},
      },
    },
  },
  {
    -- remove filetypes from tailwindcss
    "chris468-tools",
    opts = function(_, opts)
      opts = opts or {}
      opts.lsps = opts.lsps or {}
      local lsps = opts.lsps

      local tailwindcss_lsp_filetypes = vim.tbl_get(vim.lsp.config, "tailwindcss", "filetypes")
      lsps["tailwindcss-language-server"] = {
        lspconfig = {
          filetypes = tailwindcss_lsp_filetypes and vim.tbl_filter(function(ft)
            return ft ~= "markdown"
          end, tailwindcss_lsp_filetypes) or nil,
        },
      }

      return opts
    end,
  },
  {
    -- register angular plugin with vtsls
    "chris468-tools",
    opts = function(_, opts)
      opts = opts or {}
      opts.lsps = opts.lsps or {}
      local lsps = opts.lsps

      local mason_path = require("mason-core.installer.InstallLocation").global():get_dir()
      local angular_plugin = {
        name = "@angular/language-server",
        location = string.format(
          "%s/packages/angular-language-server/node_modules/@angular/language-server",
          mason_path
        ),
      }
      lsps.vtsls = {
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
