-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("chris468_tabsize", {}),
  callback = function(args)
    local tabs = require("chris468.config.tabs")
    local bo = vim.bo[args.buf]
    local ft = bo.filetype
    local setting = tabs[ft]

    if type(setting) == "number" then
      bo.shiftwidth = setting
      bo.tabstop = setting
      bo.expandtab = true
    elseif type(setting) == "table" then
      if setting[1] then
        bo.shiftwidth = setting[1]
        bo.tabstop = setting[1]
      end

      if setting.shiftwidth then
        bo.shiftwidth = setting.shiftwidth
      end
      if setting.tabstop then
        bo.tabstop = setting.tabstop
      end
      if setting.expandtab ~= nil then
        bo.expandtab = setting.expandtab
      end
    end
  end,
})
