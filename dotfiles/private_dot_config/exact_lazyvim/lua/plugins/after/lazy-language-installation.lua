return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    opts = function(_, opts)
      local M = {}
      M.p = opts.ensure_installed
      function M.callback()
        local registry = require("mason-registry")
        local languages = { none = {} }
        for _, name in ipairs(M.p) do
          local package = registry.get_package(name)
          if #package.spec.languages == 0 then
            languages.none[package.name] = true
          else
            for _, language in ipairs(package.spec.languages) do
              languages[language] = languages[language] or {}
              vim.list_extend(languages[language], { package.name })
            end
          end
        end
        vim.notify(vim.inspect(languages))
      end
      opts.ensure_installed = {}

      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = M.callback,
      })
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
