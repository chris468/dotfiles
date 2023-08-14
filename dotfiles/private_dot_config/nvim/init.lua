local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local profiles = require("chris468.profiles")

local spec = {
  { "LazyVim/LazyVim", import = "lazyvim.plugins" },
}
profiles.append_specs(spec)

require("lazy").setup({ spec = spec })
