vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("chris468.highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "Search", timeout = 350 })
  end,
})
