return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts._servers = opts.servers
      opts.servers = {}

      opts._setup = opts.setup
      opts.setup = {}
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = {}
    end,
  },
}
