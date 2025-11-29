local mapping = Chris468.options.git.primary == "neogit" and "<leader>gg" or "<leader>gG"
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
      { "<leader>gC", "<cmd>Neogit commit<cr>", "Neogit commit" },
    },
  },
}
