return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = { nushell = {} },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      { "nushell/tree-sitter-nu" },
    },
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "nu" })
      end
    end,
  },
}
