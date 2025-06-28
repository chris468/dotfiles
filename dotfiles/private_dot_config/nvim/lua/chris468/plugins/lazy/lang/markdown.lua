return {
  {
    "chris468-tools",
    opts = {
      lsps = { marksman = {} },
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
      linters_by_ft = {
        markdown = {
          markdown = { "markdownlint-cli2" },
          ["markdown.mdx"] = { "markdownlint-cli2" },
        },
      },
    },
  },
}
