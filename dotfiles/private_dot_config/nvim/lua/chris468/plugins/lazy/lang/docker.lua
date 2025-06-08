return {
  {
    "nvim-lspconfig",
    opts = {
      dockerls = {},
      docker_compose_language_service = {},
    },
  },
  {
    "nvim-lint",
    opts = {
      linters_by_ft = {
        docker = {
          dockerfile = { "hadolint" },
        },
      },
    },
  },
}
