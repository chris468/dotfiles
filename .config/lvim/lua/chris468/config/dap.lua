local mason_dap = require("mason-nvim-dap")

local M = {}

function M.config()
  lvim.chris468.dap = {
    ensure_installed = {}
  }

  lvim.builtin.dap.on_config_done = function(dap)
    require("chris468.config.dap").setup(dap)
  end

end

function M.setup(_)
  mason_dap.setup({
    ensure_installed = lvim.chris468.dap.ensure_installed or {},
    handlers = {}
  })
end

return M
