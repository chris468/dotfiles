vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- sidebar behavior
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.showmode = false
vim.opt.signcolumn = "yes"

-- window behavior
vim.opt.confirm = true
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 8
vim.opt.splitbelow = true
vim.opt.splitright = true

-- indention
vim.opt.breakindent = true
vim.opt.shiftround = true

-- search
vim.opt.ignorecase = true
vim.opt.inccommand = "split"
vim.opt.smartcase = true

-- delays
vim.opt.timeout = true
vim.opt.timeoutlen = 300
vim.opt.updatetime = 250

local chezmoi = require("chris468.config.chezmoi")
local chris468 = {
  keymaps = {
    { "<Esc>", "<cmd>nohlsearch<CR>", desc = "Clear search hilight" },
    { "<leader>l", "<cmd>Lazy<CR>", desc = "Lazy", icon = "󰒲" },
  },
  options = {
    work = chezmoi.work,
    theme = chezmoi.theme,
  },
  tools = {
    ---@type string[] disable tooling on these filetypes
    disable = { "lazy", "lazy_backdrop", "mason" },
    ---@type chris468.config.ToolsByFiletype
    formatters = {
      python = { "black" },
      csharp = {
        {
          "csharpier",
          prerequisite = function()
            return false, "never"
          end,
        },
      },
    },
    ---@type chris468.config.ToolsByFiletype
    linters = {
      ["yaml.ansible"] = { "ansible-lint" },
    },
    ---@type chris468.config.Lsps
    lsps = {
      omnisharp = {},
      yamlls = {
        config = {
          settings = {
            yaml = {
              format = {
                enable = false,
              },
            },
          },
        },
      },
    },
  },
}
local has_overrides, overrides = pcall(require, "chris468.config.local")

_G.Chris468 = vim.tbl_deep_extend("force", chris468, has_overrides and overrides or {})
