local lspconfig = require("lspconfig")
local lspconfig_to_package = require("mason-lspconfig.mappings.server").lspconfig_to_package
local registry = require("mason-registry")

local M = {}

local function install(package_name, callback)
  callback = callback or function() end
  if registry.is_installed(package_name) then
    callback()
    return
  end

  local pkg = registry.get_package(package_name)
  if not pkg then
    callback()
    return
  end

  vim.notify("Installing " .. pkg.name .. "...")
  pkg:install():once("closed", function()
    if pkg:is_installed() then
      vim.notify("Successfully installed " .. pkg.name .. ".")
      vim.schedule(callback)
    else
      vim.notify("Failed to install " .. pkg.name .. ".", vim.log.levels.WARN)
    end
  end)
end

function M.wrap_setup_with_lazy_install(original_setup)
  return function(server, opts)
    local desc = "set up " .. server
    local package_name = lspconfig_to_package[server]
    if package_name then
      desc = "install " .. package_name .. " and " .. desc
    end

    local function setup()
      if not original_setup or not original_setup(server, opts) then
        lspconfig[server].setup(opts)
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        if package_name then
          install(package_name, setup)
        else
          setup()
        end

        return true
      end,
      group = vim.api.nvim_create_augroup(desc, { clear = true }),
      pattern = opts.filetypes or lspconfig[server].config_def.default_config.filetypes,
    })
  end
end

return M
