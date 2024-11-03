local daps = require("lazy-mason-install.daps")
local formatters = require("lazy-mason-install.formatters")
local linters = require("lazy-mason-install.linters")
local lsps = require("lazy-mason-install.lsps")
local util = require("chris468.util")

local M = {}

---@class lazy-mason-install.Config
---@field packages string[]?
---@field lsp_servers string[]?
---@field additional_packages_by_ft table<string, string[]>?
---@field all string[]?

---@type lazy-mason-install.Config
local defaults = {
  packages = {},
  lsp_servers = {},
  additional_packages_by_ft = {},
}

---@type lazy-mason-install.Config
local config

---@param user_config lazy-mason-install.Config
function M.setup(user_config)
  config = vim.tbl_deep_extend("keep", user_config, defaults)
  vim.notify("lazy-mason-install " .. vim.inspect(config))

  ---@type table<string, true>
  local packages_with_unknown_filetypes = {}
  local install_for_filetypes = {}
  local packages = vim.list_extend(lsps.to_packages(config.lsp_servers), config.packages)
  local packages_to_filetypes =
    util.merge_list_maps(daps.to_filetypes(), formatters.to_filetypes(), linters.to_filetypes(), lsps.to_filetypes())

  for _, package in ipairs(packages) do
    if not install_for_filetypes[package] then
      local filetypes = packages_to_filetypes[package]
      if filetypes then
        install_for_filetypes[package] = filetypes
      else
        packages_with_unknown_filetypes[package] = true
        install_for_filetypes[package] = { "*" }
      end
    end
  end

  if not vim.tbl_isempty(packages_with_unknown_filetypes) then
    vim.notify(
      "Could not associate packages with filetype, always installing: \n  "
        .. table.concat(vim.tbl_keys(packages_with_unknown_filetypes), "\n  "),
      vim.log.levels.WARN
    )
  end

  local packages_by_filetype = util.invert_list_map(install_for_filetypes)
  vim.notify(vim.inspect(packages_by_filetype))
end

return M
