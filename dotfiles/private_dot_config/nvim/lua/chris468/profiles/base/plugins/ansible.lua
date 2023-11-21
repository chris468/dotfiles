return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local root_pattern = require("lspconfig.util").root_pattern
      print("configing")
      return vim.tbl_deep_extend("force", opts, {
        servers = {
          ansiblels = {
            root_dir = function(filename)
              return root_pattern(".debops")(filename)
                or root_pattern(".debops.cfg")(filename)
                or root_pattern("ansible.cfg")(filename)
                or root_pattern(".ansible-lint")(filename)
            end,
          },
        },
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts["yaml.ansible"] = { "prettier" }
    end,
  },
}
