local mason_dap = require("mason-nvim-dap")

local M = {}

function M.setup(_)
  mason_dap.setup({
    ensure_installed = lvim.chris468.dap.ensure_installed or {},
    handlers = {}
  })
end

return M
