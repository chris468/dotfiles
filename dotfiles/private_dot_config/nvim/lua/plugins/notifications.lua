return {
  {
    "folke/snacks.nvim",
    opts = {
      notifier = { enabled = false },
    },
  },
  {
    "folke/noice.nvim",
    lazy = false,
    opts = {
      messages = {
        enabled = true,
        view = "mini",
        view_error = "mini",
        view_warn = "mini",
        view_history = "messages",
        view_search = "virtualtext",
      },
      notify = {
        enabled = true,
        view = "mini",
      },
    },
  },
}
