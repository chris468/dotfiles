local Tool = require("chris468-tools.tool")
local installer = require("chris468-tools.installer")

---@class chris468.tools.Formatter : chris468.tools.Tool
---@field protected super chris468.tools.Tool
---@field new fun(self: chris468.tools.Formatter, name: string, opts?: chris468.tools.Tool.Options) : chris468.tools.Formatter
---@field by_ft { [string]: chris468.tools.Formatter[] }
---@field names_by_ft { [string]: string[] }
Formatter = Tool:extend() --[[ @as chris468.tools.Formatter ]]
Formatter.type = "formatter"
Formatter.by_ft = {}
Formatter.names_by_ft = {}
function Formatter:new(name, opts)
  opts = opts or {}
  return self:_new(name, opts) --[[ @as chris468.tools.Formatter ]]
end

---@param opts { [string]: chris468.tools.Tool.Options }
function Formatter.setup(opts)
  Formatter.by_ft, Formatter.names_by_ft = installer.map_tools_by_filetype(opts, Formatter, opts.disabled_filetype)
  installer.install_on_filetype(
    Formatter.by_ft,
    vim.api.nvim_create_augroup("chris468-tools.formatter", { clear = true })
  )
end

return Formatter
