return {
  "folke/which-key.nvim",
  opts = function(_, opts)
    opts.defaults["<leader>t"] = { name = "Terminal" }
    opts.defaults["<leader>D"] = { name = "Dotfiles" }
  end,
}
