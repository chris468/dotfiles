local getenv = require("os").getenv

return {
  {
    "chris468-notes",
    dir = (getenv("XDG_DATA_HOME") or vim.expand("~/.local/share")) .. "/chris468/neovim/plugins/notes",
    event = { "BufEnter" },
    opts = {},
  },
}
