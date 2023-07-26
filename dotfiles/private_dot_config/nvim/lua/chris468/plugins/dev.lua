return {
  { 'rafcamlet/nvim-luapad' },
  {
    "williamboman/mason.nvim",
    tag = "stable",
    build = ":MasonUpdate",
    config = function (_) require("mason").setup() end,
    cmd = {
      "Mason",
      "MasonUpdate",
      "MasonInstall",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonLog",
    },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    tag = "stable",
    dependencies = { "mason.nvim" },
    config = function (_)
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
        }
      })
      require("chris468.config.lsp")
    end,
  },
  { "neovim/nvim-lspconfig" },
}
