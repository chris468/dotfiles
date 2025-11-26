local getenv = require("os").getenv

return {
  { "nvim-lua/plenary.nvim", lazy = true, version = false },
  { "uga-rosa/utf8.nvim", lazy = true, version = false },
  { "tjdevries/lazy-require.nvim", lazy = true, version = false },
  { "nvim-neotest/nvim-nio", lazy = true },
  {
    "chris468-utils",
    dependencies = {
      "plenary.nvim",
      "utf8.nvim",
    },
    dir = (getenv("XDG_DATA_HOME") or vim.expand("~/.local/share")) .. "/chris468/neovim/plugins/utils",
    lazy = true,
  },
}
