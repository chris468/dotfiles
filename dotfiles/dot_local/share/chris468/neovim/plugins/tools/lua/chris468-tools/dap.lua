local Tool = require("chris468-tools.tool")
local installer = require("chris468-tools.installer")

---@class chris468.tools.Dap : chris468.tools.Tool
---@field protected super chris468.tools.Tool
---@field new fun(self: chris468.tools.Dap, name: string, opts?: chris468.tools.Tool.Options) : chris468.tools.Dap
---@field by_ft { [string]: chris468.tools.Dap[] }
---@field names_by_ft { [string]: string[] }
Dap = Tool:extend() --[[ @as chris468.tools.Dap ]]
Dap.type = "DAP"
function Dap:new(name, opts)
  opts = opts or {}
  return self:_new(name, opts) --[[ @as chris468.tools.Dap ]]
end

function Dap:name()
  if not self._tool_name then
    local package_to_nvim_dap = require("mason-nvim-dap.mappings.source").package_to_nvim_dap
    self._tool_name = package_to_nvim_dap[self._package_name]
  end

  return Dap.super.name(self)
end

function Dap:_tool_filetypes()
  local dap_filetypes = require("mason-nvim-dap.mappings.filetypes")
  return dap_filetypes[self:name()]
end

---@param opts { [string]: chris468.tools.Tool.Options }
---@param disable_filetypes { [string]: true }
function Dap.setup(opts, disable_filetypes)
  Dap.by_ft, _ = installer.map_tools_by_filetype(opts, Dap, disable_filetypes)
  installer.install_on_filetype(
    Dap.by_ft,
    vim.api.nvim_create_augroup("chris468-tools.dap", { clear = true })
  )
end

return Dap
