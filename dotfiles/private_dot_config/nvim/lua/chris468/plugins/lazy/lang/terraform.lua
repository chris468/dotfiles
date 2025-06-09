local have_terraform = vim.fn.executable("terraform") == 1

local terraform_validate = {
  "terraform_validate",
  package = false,
  enabled = have_terraform,
}

return {
  {
    "nvim-lspconfig",
    opts = {
      ["terraform-ls"] = {
        lspconfig = {
          filetypes = { "tf", "terraform", "terraform-vars" },
        },
      },
    },
  },
  {
    "conform.nvim",
    opts = {
      foramtters = {
        terraform = {
          terraform_fmt = {
            package = false,
            enabled = have_terraform,
            filetypes = { "terraform", "terraform-vars", "tf" },
          },
        },
      },
    },
  },
  {
    "nvim-lint",
    opts = {
      linters = {
        terraform = {
          terraform_validate = {
            package = false,
            enabled = have_terraform,
            filetypes = { "terraform", "tf" },
          },
        },
      },
    },
  },
}
