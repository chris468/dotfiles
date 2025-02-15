return {
  {
    "fzf-lua",
    enabled = LazyVim.has_extra("editor.fzf"),
    keys = {
      { "<leader>r", "<cmd>FzfLua resume<cr>", desc = "Resume" },
    },
  },
}
