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
    },
  },
  {
    "conform.nvim",
    opts = {
      formatters_by_ft = {
        terraform = {
          terraform = { terraform_fmt },
          ["terraform-vars"] = { terraform_fmt },
          tf = { terraform_fmt },
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
