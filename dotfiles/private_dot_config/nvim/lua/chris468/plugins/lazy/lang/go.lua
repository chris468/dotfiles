return {
  {
    "chris468-tools",
    opts = {
      lsps = { gopls = {} },
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
