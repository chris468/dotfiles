vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  callback = function()
    if require("chris468.util.lazy").has_plugin("venv-selector.nvim") then
      local cache = require("venv-selector.cached_venv")
      cache.retrieve()
    end
  end,
})
