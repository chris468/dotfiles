local theme = require("chris468.config.chezmoi").options.theme or "tokyonight"
require("chris468.lazy").install()

require("chris468.config.options")

require("lazy").setup({
  spec = {
    { import = "chris468.plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { theme, "tokyonight", "habamax" } },
  checker = {
    enabled = true,
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        -- "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        -- "tarPlugin",
        "tohtml",
        "tutor",
        -- "zipPlugin",
      },
    },
  },
  rocks = {
    enabled = false,
  },
})
