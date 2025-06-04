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

if Chris468.options.venv.additional_filetypes and #Chris468.options.venv.additional_filetypes then
  vim.api.nvim_create_autocmd("FileType", {
    pattern = Chris468.options.venv.additional_filetypes,
    callback = function()
      if vim.list_contains(Chris468.options.venv.additional_filetypes, vim.bo.filetype) then
        local ok, cache = pcall(require, "venv-selector.cached_venv")
        if ok then
          cache.retrieve()
        end
      end
    end,
  })
end
