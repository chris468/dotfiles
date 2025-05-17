return {
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
    "rafcamlet/nvim-luapad",
    cmd = {
      "Luapad",
      "LuaRun",
      "Lua",
    },
    dependencies = { "snacks.nvim" },
    keys = {
      {
        "<leader><c-l>",
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
    "folke/snacks.nvim",
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
}
