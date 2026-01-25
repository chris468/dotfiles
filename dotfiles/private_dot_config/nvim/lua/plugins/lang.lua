return {
  {
    "mason.nvim",
    opts = function(_, opts)
      -- don't install any servers up front.
      -- config/autocmds/lang.lua will install registered linters and formatters
      opts.chris468_auto_install = opts.ensure_installed
      opts.ensure_installed = {}
      return opts
    end,
  },
  {
    "mason-lspconfig.nvim",
    init = function()
      -- don't install any servers up front.
      -- config/autocmds/lang.lua will install registered servers.
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
      -- config/autocmds/lang.lua will install registered daps
      opts.ensure_installed = {}
      return opts
    end,
  },
  {
    "noice.nvim",
    opts = function(_, opts)
      opts.routes = vim.list_extend(opts.routes or {}, {
        {
          filter = {
            cond = function(m)
              return m.opts.chris468_lang ~= nil
            end,
          },
          view = "mini",
        },
        {
          --- LazyVim angular lsp configuration uses a helper that asserts that a mason package path is present
          --- Squash that error if that package installed is not. The message can still be seen in the history.
          filter = {
            -- Cond is called even if event/kind/find don't match, so check
            -- everything in cond in order to avoid unnecessary expensive checks.
            ---@param m NoiceMessage
            cond = function(m)
              if
                m.event ~= "notify"
                or m.kind ~= "warn"
                or not m:content():find("^Mason package path not found for %*%*angular%-language%-server%*%*")
              then
                return false
              end

              local registry = require("mason-registry")
              local ok, pkg = pcall(registry.get_package, "angular-language-server")
              local installed = ok and pkg:is_installed()
              return not installed
            end,
          },
          opts = { skip = true },
        },
      })
      return opts
    end,
  },
  {
    "nvim-treesitter",
    opts = function(_, opts)
      -- don't install any treesitter parsers up front.
      -- config/autocmds/treesitter.lua will install parsers when needed.
      opts.ensure_installed = {}

      -- highlights controls whether LazyVim starts the parser.
      -- disable so I can control it. see config/autocmds/treesitter.lua
      opts.highlights = { enabled = false }
    end,
  },
  { import = "plugins.lang" },
}
