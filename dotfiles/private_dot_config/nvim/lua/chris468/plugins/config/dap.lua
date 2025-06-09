local tools = require("chris468.plugins.config.tools")
local util = require("chris468.util")
local M = {
  ---@type {[string]: chris468.config.Formatter[]}
  daps_by_filetype = {},
  cache = tools.cached_tool_info("dap"),
  handled_filetypes = {},
}

---@param bufnr integer
---@param callback fun()
function M.install_daps_for_filetype(bufnr, callback)
  local filetype = vim.bo[bufnr].filetype
  if M.handled_filetypes[filetype] then
    callback()
    return
  end

  M.handled_filetypes[filetype] = true

  tools.install_tools(M.daps_by_filetype[filetype], M.cache, bufnr, callback, false)
end

function M.setup(opts)
  local disabled_filetypes = util.make_set(Chris468.disable_filetypes)
  M.handled_filetypes = disabled_filetypes
  M.daps_by_filetype = tools.normalize_tools_by_ft(opts.daps_by_ft, disabled_filetypes).config_by_ft
end

return M
