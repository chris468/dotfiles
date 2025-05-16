return {
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    dependencies = { "mini.icons" },
    keys = {
      { "<leader>/", "<cmd>FzfLua live_grep<CR>", desc = "Live grep" },
      { "<leader><leader>", "<cmd>FzfLua files<CR>", desc = "Files" },
      { "<leader>fb", "<cmd>FzfLua buffers<CR>", desc = "Buffers" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<CR>", desc = "Recent files" },
      { "<leader>fz", "<cmd>FzfLua zoxide<CR>", desc = "Zoxide" },
      { "<leader>gs", "<cmd>FzfLua git_status<CR>", desc = "Git status" },
      { "<leader>r", "<cmd>FzfLua resume<CR>", desc = "Resume last search" },
      { "<leader>sh", "<cmd>FzfLua highlights<CR>", desc = "Highlights" },
      { "<leader>sk", "<cmd>FzfLua keymaps<CR>", desc = "Key maps" },
      { "<leader>uC", "<cmd>FzfLua colorschemes<CR>", desc = "Change color scheme" },
    },
    opts = {
      { "hide" },
      winopts = {
        preview = {
          layout = "vertical",
        },
      },
    },
  },
}
