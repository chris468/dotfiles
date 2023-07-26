return {
  "nvim-tree/nvim-tree.lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    config = function(_) require("nvim-tree").setup {} end,
  },
  cmd = { "NvimTreeToggle" },
}
