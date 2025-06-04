local M = {}

local config = {
  default = {
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
    virtual_lines = false,
    virtual_text = {},
  },
  lazy = {
    signs = false,
    underline = false,
    virtual_lines = false,
  },
}

setmetatable(config, {
  __index = function(t, k)
    local v = rawget(t, k)
    if v == nil then
      v = {}
      rawset(t, k, v)
    end
    return v
  end,
})

local function configure_diagnostics()
  vim.diagnostic.config({
    severity_sort = true,
    signs = function(_, bufnr)
      local filetype = vim.bo[bufnr].filetype
      return config[filetype].signs or config.default.signs
    end,
    underline = function(_, bufnr)
      local filetype = vim.bo[bufnr].filetype
      return config[filetype].underline or config.default.underline
    end,
    virtual_lines = function(_, bufnr)
      local filetype = vim.bo[bufnr].filetype
      return config[filetype].virtual_lines or config.default.virtual_lines
    end,
    virtual_text = function(_, bufnr)
      local filetype = vim.bo[bufnr].filetype
      return config[filetype].virtual_text or config.default.virtual_text
    end,
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
