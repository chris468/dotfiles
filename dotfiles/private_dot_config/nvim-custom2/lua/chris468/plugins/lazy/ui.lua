local config = require("chris468.plugins.config.lualine")
return {
  {
    "echasnovski/mini.icons",
    config = function(_, opts)
      local mi = require("mini.icons")
      mi.setup(opts)
      mi.mock_nvim_web_devicons()
    end,
    opts = {},
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "mini.icons" },
    event = "VeryLazy",
    opts = {
      sections = {
        lualine_a = { { "mode", fmt = config.format.mode } },
        lualine_b = { "filename", "branch", "diff", "diagnostics" },
        lualine_c = {},
        lualine_x = {},
        lualine_y = {
          { "lsp_status", icon = Chris468.ui.icons.lsp_status },
          { "filetype", colored = true },
          "fileformat",
          { "encoding", fmt = config.format.encoding },
        },
        lualine_z = { "progress", "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
    },
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
