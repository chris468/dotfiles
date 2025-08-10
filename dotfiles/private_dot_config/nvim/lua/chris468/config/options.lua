vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- disable startup banner
vim.opt.shortmess:append("I")

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
vim.opt.fillchars:append({
  foldopen = "",
  foldclose = "",
  foldsep = " ",
  horiz = "─",
  horizdown = "┬",
  horizup = "┴",
  vert = "│",
  vertleft = "┤",
  vertright = "├",
  verthoriz = "┼",
})

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

-- shell
if vim.fn.has("win32") == 1 then
  local shell = vim.opt.shell:get()
  if shell:match("bash") then
    vim.opt.shellcmdflag = "-s"
  elseif shell:match("cmd") or shell:match("powershell") or shell:match("pwsh") then
    vim.opt.shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
    vim.opt.shellcmdflag =
      "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
    vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
    vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
  end
end

-- folds
vim.opt.foldcolumn = "1"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

local chezmoi = require("chris468.config.chezmoi")
local chris468 = {
  ---@type string[] disable tooling on these filetypes
  disabled_filetypes = { "lazy", "lazy_backdrop", "mason", "oil" },
  ---@type { provider: "codeium"|"copilot", virtual_text: boolean, agent: "none"|"goose" }
  ai = {
    provider = chezmoi.work and "copilot" or "codeium",
    virtual_text = true,
    agent = "none",
  },
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
