return {
  "NvChad/nvim-colorizer.lua",
  event = { "BufWinEnter", "FileType", "ColorScheme" },
  opts = {
    user_default_options = {
      mode = "background",
      names = false,
    },
  },
}
