local have_terraform = vim.fn.executable("terraform") == 1

return {
  {
    "chris468-tools",
    opts = {
      lsps = {
        ["terraform-ls"] = {
          lspconfig = {
            filetypes = { "tf", "terraform", "terraform-vars" },
          },
        },
      },
      formatters = {
        terraform_fmt = {
          filetypes = { "terraform", "terraform-vars", "tf" },
          package = false,
          enabled = have_terraform,
        },
      },
      linters = {
        terraform_validate = {
          filetypes = { "terraform", "tf" },
          package = false,
          enabled = have_terraform,
        },
      },
    },
  },
}
