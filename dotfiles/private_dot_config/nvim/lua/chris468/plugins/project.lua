return {
  "ahmedkhalf/project.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  event = "VeryLazy",
  keys = {
    {
      "<leader>fp",
      function()
        local telescope = require("telescope")
        telescope.extensions.projects.projects({})
      end,
      desc = "Project",
    },
  },
  main = "project_nvim",
  opts = {
    manual_mode = true,
    silent_chdir = false,
  },
}
