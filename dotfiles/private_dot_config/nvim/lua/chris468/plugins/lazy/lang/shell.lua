return {
  {
    "chris468-tools",
    opts = {
      lsps = {
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
      formatters = {
        shfmt = { filetypes = { "bash", "sh", "zsh" } },
      },
      daps = {
        bash_debug_adapter = {},
      },
    },
  },
}
