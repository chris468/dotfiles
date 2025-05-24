vim.api.nvim_create_autocmd("User", {
  group = vim.api.nvim_create_augroup("chris468.mappings", {}),
  callback = function()
    require("chris468.config.mappings")
  end,
  once = true,
})
