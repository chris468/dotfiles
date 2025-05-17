return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "helix",
    spec = vim.list_extend({
      { "<leader>c", group = "Code" },
      { "<leader>f", group = "Files" },
      { "<leader>g", group = "Git" },
      { "<leader>s", group = "Search" },
      { "<leader>u", group = "UI" },
    }, Chris468.keymaps),
  },
}
