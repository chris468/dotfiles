return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "tsakirist/telescope-lazy.nvim",
  },
  opts = {
    extensions = {
      lazy = {
        mappings = {
          change_cwd_to_plugin = "<C-w>",
          open_plugins_picker = "<C-o>",
        },
        actions_opts = {
          change_cwd_to_plugin = {
            auto_close = true,
          },
        },
      },
    },
  },
}
