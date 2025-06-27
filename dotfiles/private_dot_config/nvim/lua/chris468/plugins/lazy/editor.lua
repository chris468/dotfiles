local cmd = require("chris468.util.keymap").cmd

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
}
