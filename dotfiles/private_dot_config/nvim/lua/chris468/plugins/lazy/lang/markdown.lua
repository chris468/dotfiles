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
      formatters_by_ft = {
        markdown = {
          markdown = { "prettier" },
          ["markdown.mdx"] = { "prettier" },
        },
      },
    },
  },
  {
    "nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {
          markdown = { "markdownlint-cli2" },
          ["markdown.mdx"] = { "markdownlint-cli2" },
        },
      },
    },
  },
}
