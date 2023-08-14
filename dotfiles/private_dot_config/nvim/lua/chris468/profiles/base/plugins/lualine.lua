return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    return {
      options = {
        theme = "nord",
        globalstatus = true,
      },
      extensions = {
        "lazy",
        "man",
        "neo-tree",
        "quickfix",
        "toggleterm",
        "trouble",
      },
      sections = {
        lualine_a = {
          {
            "filename",
            newfile_status = true,
            symbols = {
              unnamed = "󰡯", -- nf-md-file_question
              newfile = "󰝒", -- nf-md-file_question
              modified = "●",
              readonly = "󰌾", -- nf-md-lock
            },
          },
        },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = {},
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    }
  end,
}
