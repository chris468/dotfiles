vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = vim.api.nvim_create_augroup("Check for modifications", { clear = true }),
  callback = function()
    vim.cmd("checktime")
  end,
})
