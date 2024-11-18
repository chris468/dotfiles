return {
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      styles = {
        float = {
          height = 0.95,
          width = 0.99,
        },
        lazygit = {
          keys = {
            term_normal = false,
          },
          wo = {
            winbar = "Lazygit",
          },
        },
      },
    },
  },
}
