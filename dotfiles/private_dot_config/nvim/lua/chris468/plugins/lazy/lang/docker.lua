return {
  {
    "chris468-tools",
    opts = {
      lsps = {
        ["dockerfile-language-server"] = {},
        ["docker-compose-language-service"] = {},
      },
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
