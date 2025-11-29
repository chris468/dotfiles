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
