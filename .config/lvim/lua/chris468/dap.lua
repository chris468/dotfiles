local M = {}

local function load_launchjs()
  local dap_vscode = require("dap.ext.vscode")
  local filetypes = require("mason-nvim-dap.mappings.filetypes")
  dap_vscode.load_launchjs(nil, filetypes.adapter_to_configs)
end

function M.config()
  lvim.chris468.dap = {
    ensure_installed = {}
  }

  lvim.builtin.dap.on_config_done = function(dap)
    require("chris468.dap").setup(dap)
  end

end

function M.setup(_)
  local mason_dap = require("mason-nvim-dap")
  mason_dap.setup({
    ensure_installed = lvim.chris468.dap.ensure_installed or {},
    handlers = {
      mason_dap.default_setup,
      coreclr = function(config)
        mason_dap.default_setup(config)
        mason_dap.default_setup({
          name = 'netcoredbg',
          adapters = config.adapters
        })
      end
    }
  })

  local group = vim.api.nvim_create_augroup("chris468.dap", {clear = true})
  vim.api.nvim_create_autocmd(
    "DirChanged",
    {
      callback = load_launchjs,
      group = group,
    }
  )
  vim.api.nvim_create_autocmd(
    "BufWritePost",
    {
      pattern = "*/.vscode/launch.json",
      callback = load_launchjs,
      group = group,
    }
  )

  load_launchjs()

end

return M
