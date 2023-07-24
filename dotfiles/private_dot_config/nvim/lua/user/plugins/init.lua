require "user.plugins.bootstrap"
require("lazy").setup({
  {
    { "tommcdo/vim-exchange" },
    { "tpope/vim-surround" },
    {
      "dracula/vim",
      name = "dracula",
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
    },
      ft = { "fugitive" }
  },
})
