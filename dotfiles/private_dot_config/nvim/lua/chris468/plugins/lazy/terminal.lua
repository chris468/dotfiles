return {
  {
    "akinsho/toggleterm.nvim",
    cmd = { "TermExec", "TermSelect", "ToggleTerm", "ToggleTermToggleAll" },
    config = function(_, opts)
      require("toggleterm").setup(opts)
      require("chris468.util.terminal").setup()
    end,
    opts = {},
  },
}
