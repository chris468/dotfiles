vim.api.nvim_create_autocmd("FileType", {
  callback = function(arg)
    local filetype = arg.match
    local buf = arg.buf
    return require("chris468.tools").install_tools(buf, filetype)
  end,
})
