local cmd = require("chris468.util.keymap").cmd

return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    dependencies = { "which-key.nvim" },
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
    keys = {
      { "<C-h>", cmd("TmuxNavigateLeft"), desc = "Navigate left", mode = { "n", "i" } },
      { "<C-j>", cmd("TmuxNavigateDown"), desc = "Navigate down", mode = { "n", "i" } },
      { "<C-k>", cmd("TmuxNavigateUp"), desc = "Navigate up", mode = { "n", "i" } },
      { "<C-l>", cmd("TmuxNavigateRight"), desc = "Navigate right", mode = { "n", "i" } },
    },
    version = false,
  },
  {
    "which-key.nvim",
    opts = {
      icons = {
        rules = {
          { pattern = "navigate left", icon = "←", color = "green" },
          { pattern = "navigate down", icon = "↓", color = "green" },
          { pattern = "navigate up", icon = "↑", color = "green" },
          { pattern = "navigate right", icon = "→", color = "green" },
        },
      },
    },
  },
}
