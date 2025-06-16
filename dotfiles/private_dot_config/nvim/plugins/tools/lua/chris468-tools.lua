local M = {}

local function lazy_load(module)
  module = "chris468-tools." .. module
  return setmetatable({}, {
    __index = function(_, key)
      return require(module)[key]
    end,
    __call = function(...)
      return require(module)(...)
    end,
  })
end

M.formatter = lazy_load("formatter")
M.linter = lazy_load("linter")
M.lsp = lazy_load("lsp")

return M
