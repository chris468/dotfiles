return {
  {
    "chris468-tools",
    opts = {
      lsps = {
        ["dockerfile-language-server"] = {},
        ["docker-compose-language-service"] = {},
      },
      linters = {
        docker = {
          hadolint = { filetypes = { "dockerfile" } },
        },
      },
    },
  },
}
