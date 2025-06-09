return {
  {
    "nvim-lspconfig",
    opts = {
      marksman = {},
    },
  },
  {
    "conform.nvim",
    opts = {
      formatters = {
        markdown = {
          prettier = { filetypes = { "markdown", "markdown.mdx" } },
        },
      },
    },
  },
  {
    "nvim-lint",
    opts = {
      linters = {
        markdown = {
          ["markdownlint-cli2"] = { filetypes = { "markdown", "markdown.mdx" } },
        },
      },
    },
  },
}
