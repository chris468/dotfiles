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
    verion = "*",
  },
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
    verion = "*",
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    lazy = true,
    opts = {},
  },
  {
    "NeogitOrg/neogit",
    dependencies = { "diffview.nvim" },
    cmd = "Neogit",
    lazy = true,
    opts = {},
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", "Neogit" },
      { "<leader>gC", "<cmd>Neogit commit<cr>", "Neogit commit" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufRead",
    opts = {},
  },
}
