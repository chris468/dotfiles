return {
  {
    "nvim-lspconfig",
    opts = {
      gopls = {},
    },
  },
  {
    "conform.nvim",
    opts = {
      formatters = {
        go = {
          goimports = { filetypes = { "go" } },
          gofumpt = { filetypes = { "go" } },
        },
      },
    },
  },
}
