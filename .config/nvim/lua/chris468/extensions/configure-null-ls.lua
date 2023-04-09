local null_ls = require 'null-ls'

local builtins = null_ls.builtins
local diagnostics = builtins.diagnostics
local formatting = builtins.formatting

null_ls.setup {
  debug = true,
  sources = {
    diagnostics.flake8,
    formatting.black,
    formatting.prettier,
  }
}
