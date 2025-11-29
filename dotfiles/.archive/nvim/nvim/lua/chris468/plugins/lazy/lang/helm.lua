return {
  { "towolf/vim-helm", ft = "helm" },
  {
    "chris468-tools",
    dependencies = { "b0o/schemastore.nvim", version = false },
    opts = {
      lsps = {
        ["helm-ls"] = {},
      },
    },
  },
}
