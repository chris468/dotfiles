if Chris468.venv.additional_filetypes and #Chris468.venv.additional_filetypes then
  vim.api.nvim_create_autocmd("FileType", {
    pattern = Chris468.venv.additional_filetypes,
    callback = function()
      if require("chris468.util.lazy").has_plugin("venv-selector.nvim") then
        local cache = require("venv-selector.cached_venv")
        cache.retrieve()
      end
    end,
  })
end
