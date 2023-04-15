local M = {}

function M.config()
  lvim.plugins = {
    {
      "dracula/vim",
      as = "dracula",
      disable = lvim.colorscheme ~= "dracula",
    },
    { "chrisbra/unicode.vim" },
    { "tommcdo/vim-exchange" },
    { "tpope/vim-surround" },
    {
      "nvim-neotest/neotest",
      tag = "v2.*",
      requires = {
        "nvim-lua/plenary.nvim",
        tag = "v0.*",
      },
      config = function(_)
        require("neotest").setup({
          adapters = { "neotest-python", "neotest-dotnet" },
        })
      end,
      module = "neotest",
    },
    {
      "nvim-neotest/neotest-python",
      requires = {
        "nvim-neotest/neotest"
      },
      module = "neotest",
      ft = { "python" },
    },
    {
      "Issafalcon/neotest-dotnet",
      tag = "v1.*",
      requires = {
        "nvim-neotest/neotest"
      },
      module = "neotest",
      ft = { "cs" },
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

