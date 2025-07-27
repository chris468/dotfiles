local minimum_version = "0.11.2"

if vim.fn.has("nvim-" .. minimum_version) ~= 1 then
  vim.notify(
    string.format("Version %s is required, current version is %s", minimum_version, vim.version()),
    vim.log.levels.ERROR
  )
  return
end

require("chris468.config.options")
local lazy_util = require("chris468.util.lazy")
lazy_util.install()

vim.filetype.add(Chris468.filetypes or {})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("chris468.filetype.qf", {}),
  pattern = "qf",
  callback = function(arg)
    vim.bo[arg.buf].buflisted = false
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("chris468.lazy.check", {}),
  pattern = { "LazyCheckPre", "LazyCheck" },
  callback = function(arg)
    local message = ({
      LazyCheckPre = "󰒲 Checking for updates...",
      LazyCheck = "󰒲 Finished checking for updates.",
    })[arg.match]

    vim.notify(message)
  end,
})

if Chris468.ai.virtual_text then
  vim.api.nvim_create_autocmd("User", {
    pattern = { "BlinkCmpMenuOpen", "BlinkCmpMenuClose" },
    group = vim.api.nvim_create_augroup("chris468.blink", {}),
    callback = function(arg)
      local cb = {
        BlinkCmpMenuOpen = function()
          if lazy_util.has_plugin("windsurf.nvim") then
            local windsurf_vt = require("codeium.virtual_text")
            windsurf_vt.clear()
          end

          if lazy_util.has_plugin("copilot.lua") then
            vim.b.copilot_suggestion_hidden = true
          end
        end,
        BlinkCmpMenuClose = function()
          if lazy_util.has_plugin("windsurf.nvim") then
            local windsurf_vt = require("codeium.virtual_text")
            windsurf_vt.complete()
          end

          if lazy_util.has_plugin("copilot.lua") then
            vim.b.copilot_suggestion_hidden = false
          end
        end,
      }

      cb[arg.match]()
    end,
  })
end

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
    frequency = 4 * 60 * 60,
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
  ui = {
    icons = {
      plugin = "󰒲",
    },
  },
})
