local icons = require("chris468.config.icons")

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = { "Neotree" },
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-tree/nvim-web-devicons", optional = true },
    { "MunifTanjim/nui.nvim" },
  },
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Explorer" },
    { "<leader>be", "<cmd>Neotree toggle source=buffers<cr>", desc = "Explorer" },
  },
  opts = {
    filesystem = {
      follow_current_file = { enabled = true },
    },
    default_component_configs = {
      symbols = {
        error = icons.error,
        warn = icons.warn,
        hint = icons.hint,
        info = icons.info,
      },
    },
  },
}
