require("chris468.config.options")
require("chris468.util.lazy").install()

require("lazy").setup({
  spec = {
    { import = "chris468.plugins.lazy" },
  },
  defaults = {
    lazy = true,
    version = "*",
  },
  install = { colorscheme = { Chris468.options.theme, "tokyonight", "habamax" } },
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
