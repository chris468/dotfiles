-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local autoformat_filetype = {
  lua = true,
  markdown = true,
  terraform = true,
}

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("chris468_work_autoformat", {}),
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local autoformat = autoformat_filetype[ft] or false
    vim.b[args.buf].autoformat = autoformat
  end,
})
