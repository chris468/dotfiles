return {
  {
    "chris468-tools",
    opts = {
      lsps = { gopls = {} },
      formatters = {
        goimports = { filetypes = { "go" } },
        gofumpt = { filetypes = { "go" } },
      },
      daps = {
        delve = {},
      },
    },
  },
}
