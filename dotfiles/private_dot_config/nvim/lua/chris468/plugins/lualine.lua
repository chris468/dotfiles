local icons = require("chris468.config.icons")
local theme = require("chris468.config.settings").theme

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = {
    options = {
      theme = theme,
      globalstatus = true,
    },
    extensions = {
      "lazy",
      "man",
      "neo-tree",
      "quickfix",
      "trouble",
      "chris468.toggleterm",
      "chris468.telescope",
    },
    sections = {
      lualine_a = {
        {
          "filename",
          newfile_status = true,
          symbols = {
            unnamed = icons.unnamed,
            newfile = icons.newfile,
            modified = icons.modified,
            readonly = icons.readonly,
          },
        },
      },
      lualine_b = {
        "branch",
        "diff",
        {
          "diagnostics",
          symbols = {
            error = icons.error,
            warn = icons.warn,
            hint = icons.hint,
            info = icons.info,
          },
        },
      },
      lualine_c = {},
      lualine_x = { "encoding", "fileformat", "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  },
}
