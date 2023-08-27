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

-- According to hrsh7th/nvim-cmp/issues/835, cmp intentionally does not select
-- on completion via a commit character. Adapted this based on hrsh7th/nvim-cmp/discussions/1618.
vim.api.nvim_create_autocmd("InsertEnter", {
  group = vim.api.nvim_create_augroup("chris468_register_complete_on_commit_char", {}),
  callback = function()
    local cmp = require("cmp")
    cmp.event:on("menu_opened", function()
      vim.api.nvim_create_autocmd("InsertCharPre", {
        group = vim.api.nvim_create_augroup("chris468_complete_on_commit_char", {}),
        callback = function(_)
          local entry = cmp.get_selected_entry() or {}
          local completion_item = entry.completion_item or {}
          local commit_chars = completion_item.commitCharacters or {}
          local c = vim.v.char
          if vim.tbl_contains(commit_chars, c) then
            vim.v.char = ""
            vim.schedule(function()
              cmp.confirm()
              vim.api.nvim_feedkeys(c, "n", false)
            end)
          end
        end,
        once = true,
      })
    end)
  end,
  once = true,
})
