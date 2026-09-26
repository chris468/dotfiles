local git_signs = {
  add = { text = "┃" },
  change = { text = "┃" },
  delete = { text = "╻" },
  topdelete = { text = "╹" },
  changedelete = { text = "┃" },
  untracked = { text = "┆" },
}

LazyVim.on_load("gitsigns.nvim", function()
  vim.api.nvim_set_hl(0, "GitSignsChangeDelete", { link = "DiagnosticWarn" })
end)

return {
  {
    "luukvbaal/statuscol.nvim",
    event = "BufWinEnter",
    opts = function(_, opts)
      local builtin = require("statuscol.builtin")
      return vim.tbl_deep_extend("force", opts or {}, {
        relculright = true,
        segments = {
          { text = { builtin.foldfunc } },
          {
            sign = {
              name = { ".*" },
              text = { ".*" },
              colwidth = 1,
            },
          },
          { text = { builtin.lnumfunc } },
          {
            sign = {
              name = { "Dap.*" },
              colwidth = 1,
            },
          },
          {
            sign = {
              namespace = { "gitsigns" },
              colwidth = 1,
            },
          },
        },
      })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = git_signs,
      signs_staged = git_signs,
    },
  },
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufWinEnter",
    init = function()
      -- promise-async and lewis6991/async.nvim (pulled in by the refactoring extra) both
      -- ship a top level `lua/async.lua`, and lazy resolves `require("async")` to
      -- async.nvim, which isn't callable the way ufo expects. refactoring.nvim prefers
      -- `vim.async`, so give it async.nvim there and pin `async` to promise-async.
      -- Drop the `vim.async` line once neovim ships a builtin `vim.async` (0.13).
      local root = require("lazy.core.config").options.root
      vim.async = vim.async or loadfile(root .. "/async.nvim/lua/async.lua")()
      package.loaded["async"] = loadfile(root .. "/promise-async/lua/async.lua")()

      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    keys = {
      {
        "zR",
        function()
          require("ufo").openAllFolds()
        end,
        desc = "Open all folds",
      },
      {
        "zM",
        function()
          require("ufo").closeAllFolds()
        end,
        desc = "Close all folds",
      },
    },
    opts = {},
    version = false,
  },
}
