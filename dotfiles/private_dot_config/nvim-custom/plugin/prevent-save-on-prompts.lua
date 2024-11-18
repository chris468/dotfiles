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
