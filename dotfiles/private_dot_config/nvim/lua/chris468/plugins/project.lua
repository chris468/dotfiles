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
    },
  },
  main = "project_nvim",
  opts = {
    silent_chdir = false,
  },
}
