return {
  {
    "nvim-lspconfig",
    opts = {
      lua_ls = {
        cfg = {
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
        "<leader>ll",
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
          keys = {
            ["<leader><c-l>"] = "close",
            ["<c-/>"] = {
              "<c-/>",
              "close",
              mode = { "n", "i" },
            },
            ["<c-_>"] = {
              "<c-_>",
              "close",
              mode = { "n", "i" },
            },
          },
        },
      },
    },
  },
  {
    "jbyuki/one-small-step-for-vimkind",
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
