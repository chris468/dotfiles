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
      formatters_by_ft = {
        go = {
          go = { "goimports", "gofumpt" },
        },
      },
    },
  },
}
