local cmd = require("chris468.util.keymap").cmd

return {
  {
    "echasnovski/mini.surround",
    keys = {
      "sa",
      "sd",
      "sf",
      "sF",
      "sh",
      "sr",
      "sn",
    },
    opts = {},
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
