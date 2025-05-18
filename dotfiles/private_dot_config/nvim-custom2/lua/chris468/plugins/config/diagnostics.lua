local M = {}

local function configure_diagnostics()
  vim.diagnostic.config({
    severity_sort = true,
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = Chris468.ui.icons.error .. " ",
        [vim.diagnostic.severity.WARN] = Chris468.ui.icons.warning .. " ",
        [vim.diagnostic.severity.INFO] = Chris468.ui.icons.info .. " ",
        [vim.diagnostic.severity.HINT] = Chris468.ui.icons.hint .. " ",
      },
    },
    underline = {
      severity = {
        vim.diagnostic.severity.ERROR,
        vim.diagnostic.severity.WARN,
      },
    },
    virtual_lines = true,
  })
  return true
end

function M.setup()
  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = vim.api.nvim_create_augroup("chris468.diagnostics", { clear = true }),
    callback = configure_diagnostics,
  })
end

return M
