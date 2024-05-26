return {
  setup = function()
    vim.g.mapleader = " "

    vim.opt.confirm = true
    vim.opt.conceallevel = 0
    vim.opt.cursorline = true
    vim.opt.expandtab = true
    vim.opt.ignorecase = true
    vim.opt.number = true
    vim.opt.relativenumber = true
    vim.opt.sidescrolloff = 10
    vim.opt.scrolloff = 5
    vim.opt.showmode = false
    vim.opt.shiftwidth = 4
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
