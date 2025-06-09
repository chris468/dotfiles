return {
  { "towolf/vim-helm", ft = "helm" },
  {
    "nvim-lspconfig",
    dependencies = { "b0o/schemastore.nvim", version = false },
    opts = {
      ["helm-ls"] = {},
    },
  },
}
