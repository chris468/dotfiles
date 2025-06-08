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
      formatters_by_ft = {
        shell = {
          bash = { "shfmt" },
          sh = { "shfmt" },
          zsh = { "shfmt" },
        },
      },
    },
  },
}
