return {
  "folke/tokyonight.nvim",
  lazy = false,
  config = function()
    require("tokyonight").setup()
    vim.cmd.colorscheme("tokyonight")
  end,
}
