return {
  "kulala.nvim",
  optional = true,
  keys = {
    { "<leader>Rl", "<cmd>lua require('kulala').replay()<cr>", desc = "Replay the last request" },
    {
      "<leader>Rr",
      "<cmd>lua require('kulala').run()<cr>",
      desc = "Send the request",
      ft = "http",
      mode = { "n", "v" },
    },
    {
      "<leader>Ra",
      "<cmd>lua require('kulala').run_all()<cr>",
      desc = "Send all requests",
      ft = "http",
      mode = { "n", "v" },
    },
  },
}
