local autoformat_filetype = {
  lua = true,
  markdown = true,
}

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("chris468_work_autoformat", {}),
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    local autoformat = autoformat_filetype[ft] or false
    vim.b[args.buf].autoformat = autoformat
  end,
})
