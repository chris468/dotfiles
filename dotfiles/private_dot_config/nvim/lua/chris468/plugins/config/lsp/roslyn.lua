local util = require("lspconfig.util")

return {
  server = {
    default_config = {
      cmd = { "roslyn_lsp", "--logLevel", "Information", "--extensionLogDirectory", vim.fn.stdpath("state") },
      filetypes = { "cs" },
      root_dir = util.root_pattern({ "*.sln", "*.csproj" }),
      settings = {},
    },
  },
  lspconfig = {},
}
