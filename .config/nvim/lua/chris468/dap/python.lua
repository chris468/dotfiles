return {
  adapter = function(default)
    default.command = vim.fn.exepath('debugy-adapter')
    return default
  end
}
