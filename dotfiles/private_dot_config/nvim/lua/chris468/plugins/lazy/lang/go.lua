return {
  {
    "chris468-tools",
    opts = {
      lsps = { gopls = {} },
      formatters = {
        go = {
          goimports = { filetypes = { "go" } },
          gofumpt = { filetypes = { "go" } },
        },
      },
    },
  },
}
