require("config.autocmds.linenumbers")
require("config.autocmds.lang")

local group = vim.api.nvim_create_augroup("chris468.autocmds", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(a)
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[keeppatterns %s/\n\+\%$//e]])
    pcall(vim.api.nvim_win_set_cursor, 0, pos)
  end,
  group = group,
})
