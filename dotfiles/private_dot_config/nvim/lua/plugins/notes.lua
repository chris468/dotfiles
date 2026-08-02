local getenv = require("os").getenv

return {
  {
    "chris468-notes",
    dir = (getenv("XDG_DATA_HOME") or vim.expand("~/.local/share")) .. "/chris468/neovim/plugins/notes",
    event = { "BufEnter" },
    opts = {},
    keys = {
      {
        "<leader>Ns",
        function()
          local notes = require("chris468-notes")
          notes.sync_notes()
        end,
        desc = "Sync now",
      },
    },
  },
}
