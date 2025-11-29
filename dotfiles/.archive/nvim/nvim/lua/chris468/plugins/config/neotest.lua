local M = {}

function M.add_neotest_adapters(opts, adapters)
  opts.adapters = vim.list_extend(opts.adapters or {}, adapters)
end

return M
