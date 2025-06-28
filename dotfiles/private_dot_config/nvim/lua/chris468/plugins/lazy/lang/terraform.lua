local have_terraform = vim.fn.executable("terraform") == 1

local terraform_fmt = {
  "terraform_fmt",
  package = false,
  enabled = have_terraform,
}

local terraform_validate = {
  "terraform_validate",
  package = false,
  enabled = have_terraform,
}

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
        terraform = {
          terraform_fmt = { filetypes = { "terraform", "terraform-vars", "tf" } },
        },
      },
    },
  },
  {
    "nvim-lint",
    opts = {
      linters_by_ft = {
        terraform = {
          terraform = { terraform_validate },
          tf = { terraform_validate },
        },
      },
    },
  },
}
