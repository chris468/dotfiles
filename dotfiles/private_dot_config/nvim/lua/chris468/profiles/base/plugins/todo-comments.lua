return {
  "folke/todo-comments.nvim",
  opts = {
    highlight = {
      comments_only = false,
      pattern = [[<(KEYWORDS)>]],
      keyword = "bg",
      after = "",
    },
    keywords = {
      nord0 = { color = "#2e3440" },
      nord1 = { color = "#3b4252" },
      nord2 = { color = "#434c5e" },
      nord3 = { color = "#4c566a" },
      nord4 = { color = "#d8dee9" },
      nord5 = { color = "#e5e9f0" },
      nord6 = { color = "#eceff4" },
      nord7 = { color = "#8fbcbb" },
      nord8 = { color = "#88c0d0" },
      nord9 = { color = "#81a1c1" },
      nord10 = { color = "#5e81ac" },
      nord11 = { color = "#bf616a" },
      nord12 = { color = "#d08770" },
      nord13 = { color = "#ebcb8b" },
      nord14 = { color = "#a3be8c" },
      nord15 = { color = "#b48ead" },
    },
    search = {
      pattern = [[\b(KEYWORDS)\b]],
    },
  },
}
