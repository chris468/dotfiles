return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      if require("chris468.util.lazy").has_plugin("noice.nvim") then
        telescope.load_extension("noice")
      end
    end,
    dependencies = "plenary.nvim",
    keys = {
      { "<leader>/", require("chris468.plugins.config.search.grep"), desc = "Live grep" },
      { "<leader><leader>", "<cmd>Telescope find_files<CR>", desc = "Files" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
      -- { "<leader>fz", "<cmd>Telescope zoxide<CR>", desc = "Zoxide" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Git status" },
      { "<leader>r", "<cmd>Telescope resume<CR>", desc = "Resume last search" },
      { "<leader>sh", "<cmd>Telescope highlights<CR>", desc = "Highlights" },
      { "<leader>sk", "<cmd>Telescope keymaps<CR>", desc = "Key maps" },
      { "<leader>uC", "<cmd>Telescope colorschemes<CR>", desc = "Change color scheme" },
    },
    opts = {
      defaults = {
        layout_config = {
          prompt_position = "top",
          mirror = true,
        },
        layout_strategy = "vertical",
        sorting_strategy = "ascending",
      },
    },
  },
}
