return {
  {
    "nvim-lspconfig",
    opts = {
      ["bash-language-server"] = {
        lspconfig = {
          filetypes = { "bash", "sh", "zsh" },
        },
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
