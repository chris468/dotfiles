local lspconfig = require("lspconfig")
local lspconfig_to_package = require("mason-lspconfig.mappings.server").lspconfig_to_package
local install = require("chris468.util.mason").install

local M = {}

function M.wrap_setup_with_lazy_install(original_setup)
  return function(server, opts)
    local desc = "set up " .. server
    local package_name = lspconfig_to_package[server]
    if package_name then
      desc = "install " .. package_name .. " and " .. desc
    end

    ---@param state InstallState
    local function setup(state)
      if state == "failed" then
        return
      end

      if not original_setup or not original_setup(server, opts) then
        lspconfig[server].setup(opts)
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        if package_name then
          install(package_name, setup)
        else
          setup("not_found")
        end

        return true
      end,
      group = vim.api.nvim_create_augroup(desc, { clear = true }),
      pattern = opts.filetypes or lspconfig[server].config_def.default_config.filetypes,
    })
  end
end

return M
