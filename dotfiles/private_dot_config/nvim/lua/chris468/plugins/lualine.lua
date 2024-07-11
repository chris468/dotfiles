local icons = require("chris468.config.icons")

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = {
    options = {
      theme = auto,
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
            unnamed = icons.file.unnamed,
            newfile = icons.file.newfile,
            modified = icons.file.modified,
            readonly = icons.file.readonly,
          },
        },
      },
      lualine_b = {
        "branch",
        "diff",
        {
          "diagnostics",
          sections = { "error", "warning" },
          symbols = {
            error = icons.diagnostic.error,
            warn = icons.diagnostic.warn,
            hint = icons.diagnostic.hint,
            info = icons.diagnostic.info,
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
