local add_neotest_adapters = require("chris468/plugins/config/neotest").add_neotest_adapters

return {
  {
    "chris468-tools",
    opts = {
      lsps = { gopls = {} },
      formatters = {
        goimports = { filetypes = { "go" } },
        gofumpt = { filetypes = { "go" } },
      },
      daps = {
        delve = {},
      },
    },
  },
  {
    "neotest",
    dependencies = {
      "fredrikaverpil/neotest-golang",
    },
    opts = function(_, opts)
      add_neotest_adapters(opts, {
        require("neotest-golang")({}),
      })
    end,
  },
}
