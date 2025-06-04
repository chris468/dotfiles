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
vim.opt.laststatus = 3
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 8
vim.opt.splitbelow = true
vim.opt.splitright = true

-- indention
vim.opt.breakindent = true
vim.opt.expandtab = true
vim.opt.shiftround = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- search
vim.opt.ignorecase = true
vim.opt.inccommand = "split"
vim.opt.smartcase = true

-- delays
vim.opt.timeout = true
vim.opt.timeoutlen = 400
vim.opt.updatetime = 250

-- preserve undo stack
vim.opt.undofile = true
vim.opt.undolevels = 1000

local chezmoi = require("chris468.config.chezmoi")
local chris468 = {
  options = {
    work = chezmoi.work,
    theme = chezmoi.theme,
  },
  ---@type vim.filetype.add.filetypes
  filetypes = {
    pattern = {
      ["docker%-compose%.ya?ml"] = "yaml.docker-compose",
      ["docker%-compose%..*%.ya?ml"] = "yaml.docker-compose",
    },
  },
  tools = require("chris468.config.tools"),
  venv = {
    additional_filetypes = {
      "yaml.ansible",
    },
  },
  ui = {
    icons = {
      error = "󰅚",
      warning = "󰀪",
      info = "󰋽",
      hint = "󰌶",
      debug = "",
      trace = "✎",
      normal = "",
      insert = "",
      pending = "⋰",
      more = "…",
      visual = "󰒇",
      replace = "",
      command = "",
      shell = "󱆃",
      terminal = "",
      confirm = "",
      lsp_status = "",
      windsurf = "",
      copilot = "",
    },
  },
}
local has_overrides, overrides = pcall(require, "chris468.config.local")

_G.Chris468 = vim.tbl_deep_extend("force", chris468, has_overrides and overrides or {})
