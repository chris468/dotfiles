return {
  {
    "echasnovski/mini.surround",
    keys = {
      "gsa",
      "gsd",
      "gsf",
      "gsF",
      "gsh",
      "gsr",
      "gsn",
    },
    opts = {
      mappings = {
        add = "gsa", -- Add surrounding in Normal and Visual modes
        delete = "gsd", -- Delete surrounding
        find = "gsf", -- Find surrounding (to the right)
        find_left = "gsF", -- Find surrounding (to the left)
        highlight = "gsh", -- Highlight surrounding
        replace = "gsr", -- Replace surrounding
        update_n_lines = "gsn", -- Update `n_lines`

        suffix_last = "l", -- Suffix to search with "prev" method
        suffix_next = "n", -- Suffix to search with "next" method
      },
    },
  },
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
    verion = "*",
  },
  {
    "stevearc/oil.nvim",
    dependencies = { "mini.icons" },
    keys = {
      {
        "<leader>e",
        function()
          require("oil").toggle_float(vim.uv.cwd())
        end,
        desc = "Explore",
      },
      {
        "<leader>E",
        function()
          require("oil").toggle_float()
        end,
        desc = "Explore buffer directory",
      },
    },
    opts = {},
    lazy = false,
  },
  {
    "catgoose/nvim-colorizer.lua",
    event = { "BufWinEnter", "FileType", "ColorScheme" },
    opts = {
      user_default_options = {
        mode = "virtualtext",
        virtualtext_inline = true,
        names = false,
      },
    },
  },
  {
    "folke/snacks.nvim",
    event = "BufWinEnter",
    opts = {
      indent = {
        animate = {
          enabled = false,
        },
        indent = {
          char = "┊",
        },
        scope = {
          char = "┊",
          hl = "@keyword",
        },
      },
    },
  },
  {
    "luukvbaal/statuscol.nvim",
    event = "BufWinEnter",
    opts = function(_, opts)
      local builtin = require("statuscol.builtin")
      return vim.tbl_deep_extend("keep", opts or {}, {
        segments = {
          { text = { builtin.foldfunc } },
          {
            sign = {
              name = { ".*" },
              text = { ".*" },
              colwidth = 1,
            },
          },
          { text = { builtin.lnumfunc } },
          {
            sign = {
              namespace = { "gitsigns" },
              colwidth = 1,
            },
          },
        },
      })
    end,
  },
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufWinEnter",
    keys = {
      {
        "zR",
        function()
          require("ufo").openAllFolds()
        end,
        desc = "Open all folds",
      },
      {
        "zM",
        function()
          require("ufo").closeAllFolds()
        end,
        desc = "Close all folds",
      },
    },
    opts = {},
  },
  {
    "MisanthropicBit/decipher.nvim",
    keys = require("chris468.plugins.config.decipher").mappings(),
    opts = {},
  },
}
