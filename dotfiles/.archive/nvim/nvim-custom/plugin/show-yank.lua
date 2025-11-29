vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("show-yank", { clear = true }),
  callback = function(_)
    vim.highlight.on_yank()
  end,
})
