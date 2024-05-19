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

local config = require("chris468.profiles.config")

local spec = {
  { "LazyVim/LazyVim", import = "lazyvim.plugins" },
  { import = "chris468.profiles.base", enabled = config.profiles.base or false },
  { import = "chris468.profiles.work", enabled = config.profiles.work or false },
}

require("lazy").setup({
  spec = spec,
  lockfile = vim.fn.stdpath("config") .. "/" .. config.lockfile,
})
