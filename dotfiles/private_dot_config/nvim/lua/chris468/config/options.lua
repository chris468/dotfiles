return {
  setup = function()
    vim.g.mapleader = " "

    vim.opt.autowrite = true
    vim.opt.confirm = true
    vim.opt.conceallevel = 0
    vim.opt.cursorline = true
    vim.opt.expandtab = true
    vim.opt.formatoptions = {
      t = true, -- auto-wrap text using textwidth
      c = true, -- auto-wrap comments using text with, insert leader automatically
      r = true, -- auto-insert the current comment leader after hitting <Enter> in insert mode
      q = true, -- allow formatting of comments w/ gq
      n = true, -- when formatting text, recognize numbered lists
      l = true, -- [existing] long lines are not broken in insert mode
      j = true, -- where it makes sense, remove comment leader when joining lines
    }
    vim.opt.ignorecase = true
    vim.opt.list = true
    vim.opt.listchars = {
      tab = " ",
      trail = "␣",
      nbsp = "",
    }
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.sidescrolloff = 10
    vim.opt.scrolloff = 5
    vim.opt.shiftround = true
    vim.opt.shiftwidth = 4
    vim.opt.shortmess:append({
      W = true, -- don't give written message when writing a file
      I = true, -- don't give intro message on start
      c = true, -- don't give |ins-completion-menu| messages
      C = true, -- don't give messages while scanning for ins-completion
    })
    vim.opt.showmode = false
    vim.opt.signcolumn = "yes"
    vim.opt.smartcase = true
    vim.opt.splitbelow = true
    vim.opt.splitkeep = "screen"
    vim.opt.splitright = true
    vim.opt.tabstop = 4
    vim.opt.termguicolors = true
    vim.opt.updatetime = 2000

    if vim.fn.has("win32") == 1 then
      vim.opt.shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
      vim.opt.shellcmdflag =
        "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
      vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
      vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
      vim.opt.shellquote = ""
      vim.opt.shellxquote = ""
    end
  end,
}
