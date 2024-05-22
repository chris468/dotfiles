return {
  "rcarriga/nvim-notify",
  cond = not require("chris468.config").enable_noice,
  dependencies = {
    {
      "nvim-telescope/telescope.nvim",
      optional = true,
      keys = {
        { "<leader>fn", "<cmd>Telescope notify<cr>", desc = "Notification history" },
        { "<leader>nh", "<cmd>Telescope notify<cr>", desc = "Notification history" },
      },
    },
  },
  init = function()
    vim.notify = require("notify")
  end,
  keys = {
    {
      "<leader>nd",
      function()
        require("notify").dismiss({ pending = false, silent = false })
      end,
      desc = "Dismiss",
    },
    "<leader>fn",
    "<leader>nh",
  },
  opts = {
    max_width = function()
      return vim.o.columns * 0.8
    end,
    render = "wrapped-compact",
    stages = "fade",
    timeout = 3000,
    top_down = false,
  },
}
