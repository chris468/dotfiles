-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local autoformat_filename = {
  PKGBUILD = false,
}

local group = vim.api.nvim_create_augroup("chris468_base_autoformat_filename", {})
for pattern, autoformat in pairs(autoformat_filename) do
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = group,
    pattern = pattern,
    callback = function(args)
      vim.b[args.buf].autoformat = autoformat
    end,
  })
end

-- According to hrsh7th/nvim-cmp/issues/835, cmp intentionally does not select
-- on completion via a commit character. Adapted this based on https://github.com/hrsh7th/nvim-cmp/discussions/1618.
-- vim.api.nvim_create_autocmd("InsertEnter", {
--   group = vim.api.nvim_create_augroup("chris468_register_complete_on_commit_char", {}),
--   callback = function()
--     local cmp = require("cmp")
--     cmp.event:on("menu_opened", function()
--       vim.api.nvim_create_autocmd("InsertCharPre", {
--         group = vim.api.nvim_create_augroup("chris468_complete_on_commit_char", {}),
--         callback = function(_)
--           if not cmp.visible() then
--             return
--           end
--           local entry = cmp.get_selected_entry() or {}
--           local completion_item = entry.completion_item or {}
--           local commit_chars = completion_item.commitCharacters or {}
--           local c = vim.v.char
--           if vim.tbl_contains(commit_chars, c) then
--             vim.v.char = ""
--             vim.schedule(function()
--               cmp.confirm()
--               vim.api.nvim_feedkeys(c, "n", false)
--             end)
--           end
--         end,
--         once = true,
--       })
--     end)
--   end,
--   once = true,
-- })
