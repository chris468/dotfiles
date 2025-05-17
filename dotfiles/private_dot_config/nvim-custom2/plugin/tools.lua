local group = vim.api.nvim_create_augroup("chris468.tools", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(arg)
    local filetype = arg.match
    if not vim.list_contains(Chris468.tools.disable, filetype) then
      local buf = arg.buf
      return require("chris468.tools").install_tools(buf, filetype)
    end
  end,
})
