local linters_by_ft = {
  markdown = { "markdownlint" },
}

return {
  "mfussenegger/nvim-lint",
  config = function(_, opts)
    local lint = require("lint")
    lint.linters_by_ft = opts.linters_by_ft

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
      callback = function()
        if vim.bo.buftype ~= "help" then
          lint.try_lint()
        end
      end,
      desc = "Lint on save",
    })
  end,
  dependencies = {
    {
      "williamboman/mason.nvim",
      opts = function(_, opts)
        local linters_to_install = {}
        for ft, linters in pairs(linters_by_ft) do
          linters_to_install[ft] = {}
          for _, l in ipairs(linters) do
            linters_to_install[ft][#linters_to_install[ft] + 1] = {
              l,
              callback = function()
                local lint = require("lint")
                lint.try_lint()
              end,
            }
          end
        end

        opts.install_for_filetype = opts.install_for_filetype or {}
        opts.install_for_filetype.linter = linters_to_install
      end,
    },
  },
  opts = {
    linters_by_ft = linters_by_ft,
  },
}
