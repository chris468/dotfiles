return {
  {
    "snacks.nvim",
    dependencies = {
      "project.nvim",
    },
    opts = {
      dashboard = {
        -- Skip 1, g, and G due to muscle memory for going to beginning and end of buffer
        autokeys = "234567890abcdefhijklmnopqrstuvwxyzABCDEFHIJKLMNOPQRSTUVWXYZ",
        sections = {
          -- { section = "header" },
          -- {
          --   pane = 2,
          --   section = "terminal",
          --   cmd = "colorscript -e square",
          --   height = 5,
          --   padding = 1,
          -- },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          {
            icon = " ",
            title = "Projects",
            section = "projects",
            indent = 2,
            padding = 1,
            dirs = LazyVim.has("project.nvim") and function()
              return require("chris468.projects").get_recent_projects(Snacks.dashboard.update)
            end or nil,
          },
          { section = "keys", gap = 0, padding = 1 },
          {
            icon = " ",
            title = "Git Status",
            section = "terminal",
            enabled = function()
              return Snacks.git.get_root() ~= nil
            end,
            cmd = "git status --short --branch --renames",
            height = 5,
            padding = 1,
            ttl = 5 * 60,
            indent = 3,
          },
          { section = "startup" },
        },
      },
    },
  },
}
