local add_neotest_adapters = require("chris468/plugins/config/neotest").add_neotest_adapters

return {
  {
    "chris468-tools",
    opts = {
      lsps = {
        ["lua-language-server"] = {
          lspconfig = {
            settings = {
              Lua = {
                completion = {
                  callSnippet = "Replace",
                },
                hint = {
                  enable = true,
                  setType = false,
                  paramType = true,
                  paramName = "Disable",
                  semicolon = "Disable",
                  arrayIndex = "Disable",
                },
              },
            },
          },
        },
      },
      formatters = {
        stylua = { filetypes = { "lua" } },
      },
      daps = {
        ["local-lua-debugger-vscode"] = { filetypes = { "lua" } },
        ["nlua"] = {
          package = false,
          filetypes = { "lua" },
          adapter = function(callback, config)
            callback({
              type = "server",
              host = config.host or "127.0.0.1",
              port = config.port or 8086,
            })
          end,
          configurations = {
            {
              type = "nlua",
              request = "attach",
              name = "Attach to running Neovim instance",
            },
          },
        },
      },
    },
  },
  {
    "neotest",
    dependencies = {
      "nvim-neotest/neotest-plenary",
    },
    opts = function(_, opts)
      add_neotest_adapters(opts, {
        require("neotest-plenary"),
      })
    end,
  },
  {
    "folke/lazydev.nvim",
    cmd = { "LazyDev" },
    ft = { "lua" },
    opts_extend = { "library" },
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "blink.cmp",
    dependencies = { "lazydev.nvim" },
    opts = {
      sources = {
        per_filetype = {
          lua = { inherit_defaults = true, "lazydev" },
        },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
    },
  },
  {
    "rafcamlet/nvim-luapad",
    cmd = {
      "Luapad",
      "LuaRun",
      "Lua",
    },
    dependencies = { "snacks.nvim" },
    keys = {
      {
        "<leader>l<C-L>",
        function()
          require("chris468.plugins.config.lang.luapad").toggle()
        end,
        desc = "Luapad",
      },
    },
    opts = {
      eval_on_change = false,
      eval_on_move = false,
    },
    version = false,
  },
  {
    "snacks.nvim",
    opts = {
      win = { enable = true },
      styles = {
        Luapad = {
          position = "right",
          bo = {
            swapfile = false,
            filetype = "lua",
            bufhidden = "hide",
            buftype = "nofile",
            buflisted = false,
            modifiable = true,
          },
          wo = {
            number = true,
            relativenumber = true,
            cursorline = true,
          },
        },
      },
    },
  },
  {
    "jbyuki/one-small-step-for-vimkind",
    dependencies = { "nvim-dap", optional = true },
    keys = {
      {
        "<leader>ld",
        function()
          require("osv").launch({ port = 8086 })
        end,
        desc = "Listen for debugger",
      },
    },
    version = false,
  },
}
