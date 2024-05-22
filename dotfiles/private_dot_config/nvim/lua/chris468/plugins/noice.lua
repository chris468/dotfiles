return {
  "folke/noice.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
    {
      "nvim-telescope/telescope.nvim",
      optional = true,
      keys = {
        { "<leader>fn", "<cmd>NoiceTelescope<cr>", desc = "Recent notifications" },
      },
    },
  },
  cond = require("chris468.config").enable_noice,
  keys = {
    { "<leader>nl", "<cmd>NoiceLast<cr>", desc = "Last" },
    { "<leader>nh", "<cmd>NoiceTelescope<cr>", desc = "History" },
    { "<leader>nd", "<cmd>NoiceDismiss<cr>", desc = "Dismiss" },
    "<leader>fn",
  },
  lazy = false, -- not lazy to try and get set up before any notifcations can be raised
  opts = {
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
      },
    },
    -- you can enable a preset for easier configuration
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = false, -- add a border to hover docs and signature help
    },
    messages = {
      view = "mini",
      view_error = "mini",
      view_warn = "mini",
    },
    notify = {
      view = "mini",
    },
    views = {
      mini = {
        timeout = 5000,
      },
    },
  },
}
