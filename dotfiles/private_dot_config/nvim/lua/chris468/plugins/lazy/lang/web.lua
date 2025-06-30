local function get_angular_plugin_path()
  local mason_path = require("mason-core.installer.InstallLocation").global():get_dir()
  local plugin_path =
    string.format("%s/packages/angular-language-server/node_modules/@angular/language-server", mason_path)
  return {
    name = "@angular/language-server",
    location = plugin_path,
  }
end

local function except(e, t)
  return vim.tbl_filter(function(v)
    return v ~= e
  end, t)
end

return {
  {
    "chris468-tools",
    opts_extend = { "formatters.prettier.filetypes" },
    opts = {
      lsps = {
        ["angular-language-server"] = {},
        phpactor = {},
        ["tailwindcss-language-server"] = {
          lspconfig = function()
            local original_filetypes = vim.tbl_get(vim.lsp.config, "tailwindcss", "filetypes" or {}) or {}
            local result = {
              filetypes = except("markdown", original_filetypes),
            }
            return result
          end,
        },
        vtsls = {
          lspconfig = function()
            return {
              settings = {
                vstls = {
                  tsserver = {
                    globalPlugins = get_angular_plugin_path(),
                  },
                },
              },
            }
          end,
        },
      },
      formatters = {
        prettier = { filetypes = { "htmlangular" } },
        php_cs_fixer = { filetypes = { "php" }, package = "php-cs-fixer" },
      },
      linters = {
        phpcs = { filetypes = { "php" } },
      },
      daps = {
        ["js-debug-adapter"] = {},
        ["chrome-debug-adapter"] = {},
        ["php-debug-adapter"] = {},
      },
    },
  },
}
