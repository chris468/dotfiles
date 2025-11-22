local getenv = require("os").getenv

return {
  {
    "luascratch",
    dependencies = { "plenary.nvim", "snacks.nvim" },
    dir = (getenv("XDG_DATA_HOME") or vim.expand("~/.local/share")) .. "/chris468/neovim/plugins/luascratch",
    keys = {
      {
        "<leader>ll",
        function()
          require("luascratch").toggle()
        end,
        desc = "Scratch",
      },
    },
    opts = {},
  },
}
