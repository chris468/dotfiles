-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Prevent save prompts on modified prompt buffers (for example telescope)
vim.api.nvim_create_autocmd("QuitPre", {
  group = vim.api.nvim_create_augroup("qp", { clear = true }),
  callback = function(args)
    local buf = args.buf
    if vim.api.nvim_buf_is_valid(buf) then
      if vim.bo[buf].buftype == "prompt" then
        vim.bo[buf].modified = false
      end
    end
  end,
})
