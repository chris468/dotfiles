local mt = {}

---@class chris468.tools.Options
---@field lsps? { [string]: chris468.tools.Lsp.Options }
---@field formatters? { [string]: chris468.tools.Tool.Options }
---@field linters? { [string]: chris468.tools.Tool.Options }
---@field disable_filetypes? string[]

---@class chris468.tools
---@field formatter chris468.tools.Formatter
---@field linter chris468.tools.Linter
---@field lsp chris468.tools.Lsp
local M = setmetatable({}, mt)

function mt.__index(tbl, key)
  tbl[key] = require("chris468-tools." .. key)
  return tbl[key]
end

---@param l? any[]
---@return table<any, true>
local function to_set(l)
  return vim.iter(l or {})
      :fold({}, function(result, i)
        result[i] = true
        return result
      end)
end

function M.setup(opts)
  opts = opts or {}

  local disable_filetypes = to_set(opts.disable_filetypes)

  if opts.lsps then
    M.lsp.setup(opts.lsps, disable_filetypes)
  end

  if opts.formatters then
    M.formatter.setup(opts.formatters, disable_filetypes)
  end

  if opts.linters then
    M.linter.setup(opts.linters, disable_filetypes)
  end
end

return M
