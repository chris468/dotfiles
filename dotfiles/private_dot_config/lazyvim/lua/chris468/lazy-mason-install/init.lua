local autocmd = require("chris468.lazy-mason-install.autocmd")
local daps = require("chris468.lazy-mason-install.daps")
local formatters = require("chris468.lazy-mason-install.formatters")
local linters = require("chris468.lazy-mason-install.linters")
local lsps = require("chris468.lazy-mason-install.lsps")
local util = require("chris468.util")
local lazyvim_util = require("lazyvim.util")

local M = {}

---@alias lazy-mason-install.CheckPrerequisite fun():boolean, string

---@class lazy-mason-install.Config
---@field packages_for_filetypes table<string, string[]>? Map mason packages to file types. Can be used to map additional packages, or when the mapping cannot be determined automatically.
---@field prerequisites table<string, lazy-mason-install.CheckPrerequisite>? Map package to a function that determines whether the package can be enabled.

---@type lazy-mason-install.Config
local defaults = {
  packages_for_filetypes = {},
  prerequisites = {},
}

---@type lazy-mason-install.Config
local config

---@param user_config lazy-mason-install.Config
function M.setup(user_config)
  config = vim.tbl_deep_extend("keep", user_config, defaults)

  ---@type table<string, true>
  local packages_with_unknown_filetypes = {}
  local install_for_filetypes = {}
  local packages = vim.list_extend(lsps.to_install(), lazyvim_util.opts("mason.nvim").ensure_installed or {})
  local packages_to_filetypes = util.merge_list_maps(
    daps.to_filetypes(),
    formatters.to_filetypes(),
    linters.to_filetypes(),
    lsps.to_filetypes(),
    config.packages_for_filetypes
  )

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
  autocmd.register(packages_by_filetype, config.prerequisites)
end

---@param packages string[]
---@param ... string[]
function M.filter(packages, ...)
  local exclude = { ... }

  local updated = packages
  for _, e in ipairs(exclude) do
    if e and #e > 0 then
      updated = vim.tbl_filter(function(v)
        return not vim.list_contains(e, v)
      end, updated)
    end
  end

  return updated
end

---@class lazy-mason-install.PackagesForFiletype
---@field [integer] string? The formatters for the filetype
---@field _replace boolean? Whether to replace the default formatters for the filetype with these formatters
---@field _remove string[]? Remove the specified formatters from the defaults.

---@param packages_by_ft table<string, string[]>
---@param merge lazy-mason-install.PackagesForFiletype
---@param additional_exclusions string[]
function M.merge_and_filter_packages_by_filetype(packages_by_ft, merge, additional_exclusions)
  for ft, m in pairs(merge) do
    local merged = {}
    for _, v in ipairs(m) do
      merged[#merged + 1] = v
    end

    if m._replace then
      packages_by_ft[ft] = merged
    else
      packages_by_ft[ft] = vim.list_extend(packages_by_ft[ft] or {}, merged)
    end
  end

  for ft, packages in pairs(packages_by_ft) do
    local m = merge[ft]
    local remove = m and m._remove or {}
    packages_by_ft[ft] = M.filter(packages, remove, additional_exclusions)
  end
end

return M
