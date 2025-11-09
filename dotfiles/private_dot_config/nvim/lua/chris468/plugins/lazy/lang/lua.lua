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
        "<leader>lL",
        function()
          require("chris468.plugins.config.lang.luapad").toggle("luapad")
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
  -- {
  --   "ii14/neorepl.nvim",
  --   cmd = { "Repl" },
  --   config = function(_, opts)
  --     require("neorepl").config(opts)
  --   end,
  --   keys = {
  --     {
  --       "<leader>ll",
  --       function()
  --         require("chris468.plugins.config.lang.luapad").toggle("neorepl")
  --       end,
  --       desc = "Lua REPL",
  --     },
  --   },
  --   opts = {},
  -- },
  {
    "yarospace/lua-console.nvim",
    lazy = true,
    keys = {
      {
        "<leader>ll",
        function()
          require("chris468.plugins.config.lang.luapad").toggle("lua-console")
        end,
        desc = "Lua-console",
      },
    },
    opts = {
      buffer = {
        clear_before_eval = true,
        load_on_start = false,
      },
      mappings = {
        attach = false,
        eval_buffer = "<leader><CR>",
        messages = false,
        resize_up = false,
        resize_down = false,
      },
    },
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
    config = function()
      if require("chris468.util.lazy").has_plugin("nvim-dap") then
        local dap = require("dap")
        dap.configurations.lua = {
          {
            type = "nlua",
            request = "attach",
            name = "Attach to running Neovim instance",
          },
        }
        dap.adapters.nlua = function(callback, config)
          callback({
            type = "server",
            host = config.host or "127.0.0.1",
            port = config.port or 8086,
          })
        end
      end
    end,
    dependencies = { "nvim-dap", optional = true },
    keys = {
      {
        "<leader>ld",
        function()
          require("osv").launch({ port = 8086 })
        end,
        desc = "Listen for debugger",
      },
      "<leader>dr",
    },
    version = false,
  },
}
