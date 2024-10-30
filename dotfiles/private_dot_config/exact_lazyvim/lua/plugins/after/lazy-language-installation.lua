return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = {}
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
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
    },
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
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      vim.list_extend(opts.events, { "FileType" })

      for ft, linters in pairs(opts.linters_by_ft or {}) do
        vim.api.nvim_create_autocmd("FileType", {
          callback = function()
            local install = require("chris468.util.mason").install

            for _, linter in ipairs(linters) do
              install(linter)
            end

            return true
          end,
          desc = "Install linters for " .. ft,
          pattern = ft,
        })
      end
    end,
  },
}
