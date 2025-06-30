return {
  {
    "chris468-tools",
    opts_extend = { "formatters.prettier.filetypes" },
    opts = {
      lsps = { marksman = {} },
      formatters = {
        prettier = { filetypes = { "markdown", "markdown.mdx" } },
      },
      linters = {
        ["markdownlint-cli2"] = { filetypes = { "markdown", "markdown.mdx" } },
      },
    },
  },
}
