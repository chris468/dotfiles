local util = require("chris468.util")
local config = require("chris468.config")

--- @class chris468.config.lang.Tools
--- @field lint string[]?
--- @field format string[]?

--- @class (exact) chris468.config.lang.Lsp
--- @field config? (table | fun():table?)
--- @field register_server? table | fun():table?
--- @field package_name? string
--- @field install? boolean

--- @class (exact) chris468.config.lang.Config
--- @field lsp { [string]: false | chris468.config.lang.Lsp }
--- @field tools chris468.config.lang.Tools
local M = {}

M.lsp = {
  angularls = {},
  ansiblels = {},
  autotools_ls = {},
  bashls = {},
  clangd = {},
  cmake = {},
  cssls = {},
  docker_compose_language_service = {},
  dockerls = {},
  elixirls = {},
  erlangls = {},
  gopls = {},
  helm_ls = {},
  html = {},
  java_language_server = {},
  jsonls = {},
  lemminx = {}, -- xml
  lua_ls = {},
  mesonlsp = {},
  nil_ls = {}, -- nix
  nushell = {
    install = false,
    config = {
      filetypes = { "nu" },
    },
  },
  omnisharp = require("chris468.config.lang.omnisharp"),
  powershell_es = {},
  pyright = require("chris468.config.lang.pyright"),
  roslyn_lsp = require("chris468.config.lang.roslyn"),
  rust_analyzer = {},
  ruff = {}, -- python
  spectral = {}, -- OpenAPI
  taplo = {}, -- toml
  terraformls = {},
  tflint = {},
  tsserver = {},
  vimls = {},
  yamlls = {},
  codeqlls = {},
}

--- @type { [string]: chris468.config.lang.Tools }
M.tools = {
  markdown = {
    lint = { "markdownlint" },
  },
  lua = {
    format = { "stylua" },
  },
  python = {
    format = { "black" },
  },
  javascript = {
    format = { "prettierd", "prettier" },
  },
}

return M
