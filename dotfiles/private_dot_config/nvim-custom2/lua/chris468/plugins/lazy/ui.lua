return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "mini.icons" },
    event = "VeryLazy",
    opts = {},
  },
  {
    "rcarriga/nvim-notify",
    init = function()
      vim.notify = require("notify")
    end,
    opts = {
      icons = {
        ERROR = Chris468.ui.icons.error,
        WARN = Chris468.ui.icons.warning,
        INFO = Chris468.ui.icons.info,
        DEBUG = Chris468.ui.icons.debug,
        TRACE = Chris468.ui.icons.trace,
      },
      render = "compact",
      timeout = 1000,
      top_down = false,
    },
  },
}
