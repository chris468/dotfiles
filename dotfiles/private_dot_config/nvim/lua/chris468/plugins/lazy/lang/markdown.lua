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
      linters = {
        markdown = {
          ["markdownlint-cli2"] = { filetypes = { "markdown", "markdown.mdx" } },
        },
      },
    },
  },
}
