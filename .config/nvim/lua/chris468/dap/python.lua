return {
  adapter = function(default)
    if not default.command or default.command == '' then
      default.command = vim.fn.exepath('debugy-adapter')
    end
    if not default.command or default.command == '' then
      print('debugpy-adapter not found')
    end
    return default
  end
}
