local colors = {
  nord1 = "#3B4252",
  nord8 = "#88C0D0",
}

return {
  "s1n7ax/nvim-window-picker",
  opts = {
    highlights = {
      statusline = {
        focused = {
          bg = colors.nord1,
          fg = colors.nord8,
          bold = true,
        },
        unfocused = {
          bg = colors.nord1,
          fg = colors.nord8,
          bold = true,
        },
      },
    },
  },
}
