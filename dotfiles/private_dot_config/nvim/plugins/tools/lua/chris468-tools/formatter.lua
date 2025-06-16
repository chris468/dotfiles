local Tool = require("chris468-tools.tool").Tool
local util = require("chris468-tools._util")
local installer = require("chris468-tools.installer")

local M = {}

---@class chris468.tools.Formatter : chris468.tools.Tool
---@field protected super chris468.tools.Tool
---@field new fun(self: chris468.tools.Formatter, name: string, opts?: chris468.tools.Tool.Options) : chris468.tools.Formatter
M.Formatter = Tool:extend() --[[ @as chris468.tools.Formatter ]]
M.Formatter.type = "formatter"
function M.Formatter:new(name, opts)
  opts = opts or {}
  return self:_new(name, opts) --[[ @as chris468.tools.Formatter ]]
end

---@param opts { [string]: { [string]: chris468.tools.Tool } }
function M.setup(opts)
  local disabled_filetypes = util.make_set(Chris468.disable_filetypes)
  local tools_by_ft, names_by_ft = installer.map_tools_by_ft(opts, M.Formatter)
  require("conform").setup(vim.tbl_extend("keep", { formatters_by_ft = names_by_ft }, opts))
  lazily_install_tools_by_filetype(tools_by_ft, disabled_filetypes, "formatter")
end

return M
