return {
  { "towolf/vim-helm", ft = "helm" },
  {
    "chris468-tools",
    dependencies = { "b0o/schemastore.nvim", version = false },
    opts = {
      ["helm-ls"] = {},
    },
  },
}
