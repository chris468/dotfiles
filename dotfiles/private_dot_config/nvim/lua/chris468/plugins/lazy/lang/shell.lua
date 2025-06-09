return {
  {
    "nvim-lspconfig",
    opts = {
      ["bash-language-server"] = {
        lspconfig = {
          filetypes = { "bash", "sh", "zsh" },
        },
      },
      nushell = {
        enable = vim.fn.executable("nu") == 1,
        package = false,
      },
    },
  },
  {
    "conform.nvim",
    opts = {
      formatters = {
        shell = {
          shfmt = { filetypes = { "bash", "sh", "zsh" } },
        },
      },
    },
  },
}
