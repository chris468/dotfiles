local M = {}

function M.config()
  lvim.plugins = {
    {
      "dracula/vim",
      name = "dracula",
    },
    {
      "chrisbra/unicode.vim",
      init = function(_)
        vim.g.Unicode_no_default_mappings = true
      end,
    },
    { "tommcdo/vim-exchange" },
    { "tpope/vim-surround" },
    {
      "nvim-neotest/neotest",
      version = "v3.*",
      dependencies = {
        "nvim-lua/plenary.nvim",
      },
      config = function(_) require('chris468.testrunner').setup() end,
    },
    {
      "nvim-neotest/neotest-python",
      dependencies = {
        "nvim-neotest/neotest"
      },
    },
    {
      "Issafalcon/neotest-dotnet",
      version = "v1.*",
      dependencies = {
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
      version = "v2.0.0", -- 2.0.1 uses a new function, not available in lvim's current mason-registry
    },
    {
      "rafcamlet/nvim-luapad",
      cmd = { "Luapad", "Luarun" },
    },
    { "pearofducks/ansible-vim" },
  }
end

return M
