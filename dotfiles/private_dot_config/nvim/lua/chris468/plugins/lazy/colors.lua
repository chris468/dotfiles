local theme = {
  catppuccin = Chris468.options.theme:find("^catppuccin") and true or false,
  nord = Chris468.options.theme == "nord",
  tokyonight = Chris468.options.theme:find("^tokyonight") and true or false,
}

return {
  {
    "folke/tokyonight.nvim",
    config = function(_, opts)
      require("tokyonight").setup(opts)
      if theme.tokyonight then
        vim.cmd.colorscheme(Chris468.options.theme)
      end
    end,
    event = "VeryLazy",
    lazy = not theme.tokyonight,
    opts = {
      on_highlights = function(hl, c)
        hl.WinSeparator = hl.WinSeparator or {}
        hl.WinSeparator.fg = c.comment
      end,
    },
    version = false,
  },
  {
    "catppuccin/nvim",
    config = function()
      require("catppuccin").setup()
      if theme.catppuccin then
        vim.cmd.colorscheme(Chris468.options.theme)
      end
    end,
    event = "VeryLazy",
    lazy = not theme.catppuccin,
    name = "catppuccin",
  },
  {
    "nordtheme/vim",
    config = function()
      if theme.nord then
        vim.cmd.colorscheme(Chris468.options.theme)
      end
    end,
    event = "VeryLazy",
    init = function()
      vim.g.nord_cursor_line_number_background = 1
    end,
    lazy = not theme.nord,
    name = "nord",
    version = false,
  },
}
