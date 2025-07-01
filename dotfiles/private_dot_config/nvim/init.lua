require("chris468.config.options")
require("chris468.util.lazy").install()

local minimum_version = "0.11.2"

if vim.fn.has("nvim-" .. minimum_version) ~= 1 then
  vim.notify(
    string.format("Version %s is required, current version is %s", minimum_version, vim.version()),
    vim.log.levels.ERROR
  )
  return
end

vim.filetype.add(Chris468.filetypes or {})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("chris468.filetype.qf", {}),
  pattern = "qf",
  callback = function(arg)
    vim.bo[arg.buf].buflisted = false
  end,
})

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
