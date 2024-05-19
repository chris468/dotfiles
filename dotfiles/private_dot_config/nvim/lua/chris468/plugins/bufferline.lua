return {
  "akinsho/bufferline.nvim",
  cmd = { "BufferLineDeleteOthers", "BufferLineCycleNext", "BufferLineCyclePrev" },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  keys = {
    { "<leader>bb", "<cmd>e #<cr>", desc = "Last" },
    { "<leader>bd", "<cmd>bd<cr>", desc = "Delete current" },
    { "<leader>bo", "<cmd>BufferLineDeleteOthers<cr>", desc = "Delete others" },
    { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
    { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
  },
  opts = {
    options = {
      always_show_bufferline = false,
      offsets = {
        {
          filetype = "neo-tree",
          text = "Explorer",
        },
      },
    },
  },
  version = "*",
}
