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
---@field install lazy-mason-install.Config
---@field formatters table<string, Chris468.Options.Lsp.FormattersForFiletype>
---@class Chris468.Options
---@field ai "None"|"Codeium"|"Copilot"|nil,
---@field lsp Chris468.Options.Lsp

local chris468 = {
  ---@type Chris468.Options
  options = {
    ai = chezmoi.options.work and "Copilot" or "Codeium",
    lsp = {
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
        },
        prerequisites = {
          ["nil"] = function()
            return vim.fn.executable("nix") == 1, "nix package manager"
          end,
        },
      },
      formatters = {
        cs = {
          _remove = { "csharpier" },
        },
        markdown = {
          "prettier",
        },
      },
    },
  },
}

local overrides = require("config.local")

_G.Chris468 = vim.tbl_deep_extend("error", vim.tbl_deep_extend("force", chris468, overrides), chezmoi)
