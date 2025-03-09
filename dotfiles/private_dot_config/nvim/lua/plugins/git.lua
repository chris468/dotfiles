return {
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
    },
  },
}
