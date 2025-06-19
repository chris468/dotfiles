local Tool = require("chris468-tools.tool")
local util = require("chris468-tools._util")
local installer = require("chris468-tools.installer")

---@class chris468.tools.Formatter : chris468.tools.Tool
---@field protected super chris468.tools.Tool
---@field new fun(self: chris468.tools.Formatter, name: string, opts?: chris468.tools.Tool.Options) : chris468.tools.Formatter
Formatter = Tool:extend() --[[ @as chris468.tools.Formatter ]]
Formatter.type = "formatter"
function Formatter:new(name, opts)
  opts = opts or {}
  return self:_new(name, opts) --[[ @as chris468.tools.Formatter ]]
end

function Formatter.on_installed(bufnr)
  util.raise_filetype(bufnr)
end

---@param opts { [string]: { [string]: chris468.tools.Tool } }
function Formatter.setup(opts)
  local tools_by_ft, names_by_ft = installer.map_tools_by_ft(opts, Formatter, opts.disabled_filetype)
  require("conform").setup(vim.tbl_extend("keep", { formatters_by_ft = names_by_ft }, opts))
  installer.install_on_filetype(tools_by_ft, vim.api.nvim_create_augroup("chris468-tools.formatter", { clear = true }))
end

return Formatter
