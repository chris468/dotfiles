local add_neotest_adapters = require("chris468/plugins/config/neotest").add_neotest_adapters

return {
  {
    "chris468-tools",
    opts = {
      lsps = { omnisharp = {} },
      daps = { netcoredbg = {} },
    },
  },
  {
    "neotest",
    dependencies = {
      "Issafalcon/neotest-dotnet",
    },
    opts = function(_, opts)
      add_neotest_adapters(opts, {
        require("neotest-dotnet")({
          discovery_root = "solution",
        }),
      })
    end,
  },
}
