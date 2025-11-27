return {
  {
    "mason.nvim",
    opts = function(_, opts)
      -- don't install any servers up front.
      -- config/autocmds/lsp.lua will install registered linters and formatters
      opts.chris468_auto_install = opts.ensure_installed
      opts.ensure_installed = {}
      return opts
    end,
  },
  {
    "mason-lspconfig.nvim",
    init = function()
      -- don't install any servers up front.
      -- config/autocmds/lsp.lua will install registered servers.
      -- LazyVim calls mason-lspconfig directly so wrap it and disable ensure_installed
      local mls = require("mason-lspconfig")
      local original = mls.setup
      ---@diagnostic disable-next-line: duplicate-set-field
      mls.setup = function(opts)
        opts.ensure_installed = {}
        original(opts)
      end
    end,
  },
  {
    "mason-nvim-dap.nvim",
    opts = function(_, opts)
      -- don't install any daps up front.
      -- config/autocmds/lsp.lua will install registered daps
      opts.ensure_installed = {}
      return opts
    end,
  },
}
