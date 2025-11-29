return {
  "ahmedkhalf/project.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  event = "VeryLazy",
  keys = {
    {
      "<leader>p",
      function()
        local telescope = require("telescope")
        telescope.extensions.projects.projects({})
      end,
      desc = "Select project",
    },
    { "<leader>P", "<cmd>ProjectRoot<cr>", desc = "Set project for current file" },
  },
  main = "project_nvim",
  opts = {
    manual_mode = true,
    silent_chdir = false,
  },
}
