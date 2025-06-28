local mt = {}

---@class chris468.tools.Options
---@field lsps? { [string]: chris468.tools.Lsp.Options }
---@field formatters? { [string]: { [string]: chris468.tools.Tool.Options } }
---@field linters? { [string]: { [string]: chris468.tools.Tool.Options } }

---@class chris468.tools
---@field formatter chris468.tools.Formatter
---@field linter chris468.tools.Linter
---@field lsp chris468.tools.Lsp
local M = setmetatable({}, mt)

function mt.__index(tbl, key)
  tbl[key] = require("chris468-tools." .. key)
  return tbl[key]
end

function M.setup(opts)
  opts = opts or {}

  if opts.lsps then
    M.lsp.setup(opts.lsps)
  end

  if opts.formatters then
    M.formatter.setup(opts.formatters)
  end

  if opts.linters then
    M.linter.setup(opts.linters)
  end
end

return M
