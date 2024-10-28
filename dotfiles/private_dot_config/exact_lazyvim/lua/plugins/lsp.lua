return {
  {
    "williamboman/mason.nvim",
    config = function(_, opts)
      -- LazyVim's `config` for mason installs all packages in `opts.ensure_installed`
      -- and registers w/ mason registry to emit `FileType` on any successful package
      -- install.
      --
      -- Instead, we will install (if necessary) when required by the current filetype,
      -- and only emit `FileType` once all have finished installing.
      vim.notify("mason setup")
      require("mason").setup({ opts })
    end,
  },
  {
    "williambowman/mason-lspconfig.nvim",
    opts = function(_, opts)
      local mlspc = require("mason-lspconfig")

      -- LazyVim's `config` for lspconfig installs all registered servers by passing
      -- them as `ensure_installed` to mason-lspconfig setup.
      --
      -- Instead, we want to install (if necessary) when required by the current filetype.
      -- LazyVim's lspconfig config does a bunch of other stuff that we still want to do,
      -- so replace mason-lspconfig's `setup` to ignore `ensure_installed`.
      local original = mlspc.setup
      mlspc.setup = function(o)
        vim.notify("mason-lspconfig setup")
        original(vim.tbl_extend("force", o, { ensure_installed = {} }))
      end

      return opts
    end,
  },
}
