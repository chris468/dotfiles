local M = {}

function M.config()
  lvim.plugins = {
    {
      "dracula/vim",
      as = "dracula",
    },
    {
      "chrisbra/unicode.vim",
      setup = function(_)
        vim.g.Unicode_no_default_mappings = true
      end,
    },
    { "tommcdo/vim-exchange" },
    { "tpope/vim-surround" },
    {
      "nvim-neotest/neotest",
      tag = "v3.*",
      requires = {
        "nvim-lua/plenary.nvim",
      },
      config = function(_) require('chris468.testrunner').setup() end,
    },
    {
      "nvim-neotest/neotest-python",
      requires = {
        "nvim-neotest/neotest"
      },
    },
    {
      "Issafalcon/neotest-dotnet",
      tag = "v1.*",
      requires = {
        "nvim-neotest/neotest"
      },
    },
    {
      "folke/trouble.nvim",
      cmd = "TroubleToggle",
    },
    {
      "tpope/vim-fugitive",
      cmd = {
        "G",
        "Git",
        "Gdiffsplit",
        "Gvdiffsplit",
        "Gread",
        "Gwrite",
        "Ggrep",
        "GMove",
        "GDelete",
        "GBrowse",
        "GRemove",
        "GRename",
        "Glgrep",
        "Gedit"
      },
      ft = { "fugitive" }
    },
    {
      "jay-babu/mason-nvim-dap.nvim",
      tag = "v2.0.0", -- 2.0.1 uses a new function, not available in lvim's current mason-registry
    },
    {
      "rafcamlet/nvim-luapad",
      cmd = { "Luapad", "Luarun" },
    },
  }
end

return M

