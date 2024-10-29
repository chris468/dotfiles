return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local lspu = require("chris468.util.lspconfig")

      local wrapped_setup = {}
      for n, _ in pairs(opts.servers) do
        opts.servers[n].mason = false
        wrapped_setup[n] = lspu.wrap_setup_with_lazy_install(opts.setup[n])
      end

      if opts.setup["*"] then
        wrapped_setup["*"] = lspu.wrap_setup_with_lazy_install(opts.setup["*"])
      end

      opts.setup = wrapped_setup
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = {}
    end,
  },
  {
    "folke/noice.nvim",
    opts = {
      routes = {
        {
          filter = { event = "notify", kind = "warn", find = "^Mason package path not found for " },
          opts = { skip = true },
        },
      },
    },
  },
}
