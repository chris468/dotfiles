local enable_noice = require("chris468.config").enable_noice

local dependencies = enable_noice
    and {
      {
        "nvim-telescope/telescope.nvim",
        optional = true,
        keys = {
          { "<leader>fn", "<cmd>Telescope notify<cr>", desc = "Notification history" },
          { "<leader>nh", "<cmd>Telescope notify<cr>", desc = "Notification history" },
        },
      },
    }
  or nil

local keys = enable_noice
    and {
      {
        "<leader>nd",
        function()
          require("notify").dismiss({ pending = false, silent = false })
        end,
        desc = "Dismiss",
      },
      "<leader>fn",
      "<leader>nh",
    }
  or nil

return {
  "rcarriga/nvim-notify",
  dependencies = dependencies,
  init = function()
    if enable_noice then
      vim.notify = require("notify")
    end
  end,
  keys = keys,
  opts = {
    max_width = function()
      return math.floor(vim.o.columns * 0.8)
    end,
    render = "wrapped-compact",
    stages = "fade",
    timeout = 3000,
    top_down = true,
  },
}
