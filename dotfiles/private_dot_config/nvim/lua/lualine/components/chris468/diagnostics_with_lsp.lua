local M = require("lualine.components.diagnostics"):extend()

local defaults = {
  ignore_clients = { "copilot" },
  lsp_icon = " ",
  auto_format_color = {
    [true] = "DiagnosticHint",
    [false] = "Comment",
  },
}

---@private
function M:_current_buffer_has_clients()
  local clients = vim.tbl_filter(function(client)
    return not vim.list_contains(self.options.ignore_clients, client.name)
  end, vim.lsp.get_clients({ buf = vim.api.nvim_get_current_buf() }))
  return #clients > 0
end

function M:init(options)
  M.super.init(self, options)
  self.options = vim.tbl_deep_extend("keep", self.options or {}, defaults)
  self.options.auto_format_hl = vim.tbl_map(function(v)
    return self:create_hl(v)
  end, self.options.auto_format_color)
end

function M:update_status()
  local result = ""
  if self:_current_buffer_has_clients() then
    local color = self.options.auto_format_hl[LazyVim.format.enabled()]
    result = self:format_hl(color) .. self.options.lsp_icon
  end
  result = result .. (self.super.update_status(self) or "")
  result = result:gsub("%s*$", "")
  return result
end

return M
