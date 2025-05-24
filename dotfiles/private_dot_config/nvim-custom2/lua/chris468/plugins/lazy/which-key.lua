return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "helix",
    spec = vim.list_extend({
      { "<leader>c", group = "Code" },
      { "<leader>f", group = "Files" },
      { "<leader>g", group = "Git" },
      { "<leader>l", group = "Lua", icon = "󰢱" },
      { "<leader>s", group = "Search" },
      { "<leader>u", group = "UI" },
    }, require("chris468.config.mappings")),
  },
}
