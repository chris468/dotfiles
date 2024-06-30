return {
  "akinsho/bufferline.nvim",
  cmd = { "BufferLineDeleteOthers", "BufferLineCycleNext", "BufferLineCyclePrev" },
  config = true,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  keys = {
    { "<leader>bb", "<cmd>e #<cr>", desc = "Last" },
    { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Delete others" },
    { "<C-S-H>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
    { "<C-S-L>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
  },
}
