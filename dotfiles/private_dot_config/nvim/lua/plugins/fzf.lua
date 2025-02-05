return {
  {
    "fzf-lua",
    enabled = LazyVim.pick.want() == "fzf",
    keys = {
      { "<leader>r", "<cmd>FzfLua resume<cr>", desc = "Resume" },
    },
  },
}
