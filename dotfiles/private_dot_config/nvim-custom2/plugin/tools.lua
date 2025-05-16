vim.api.nvim_create_autocmd("FileType", {
  callback = function(arg)
    local filetype = arg.match
    if not vim.list_contains(Chris468.tools.disable, filetype) then
      local buf = arg.buf
      return require("chris468.tools").install_tools(buf, filetype)
    end
  end,
})
