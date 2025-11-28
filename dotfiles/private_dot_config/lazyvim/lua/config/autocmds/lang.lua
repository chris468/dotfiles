local installed_filetypes = {}

---@param name? string
---@return Package?
local function get_package(name)
  if not name then
    return nil
  end
  local registry = require("mason-registry")
  local ok, package = pcall(registry.get_package, name)
  return ok and package or nil
end

local function spinner()
  return require("noice.util.spinners").spin()
end

---@type { [string]: { description: string, status: "installing"|"failed"|"success" } }
local installing = {}

local function monitor(id)
  vim.defer_fn(function()
    local state = installing[id]
    if not state then
      return
    end

    local msg, level
    if state.status == "installing" then
      msg = ("%s Installing %s..."):format(spinner(), state.description)
    elseif state.status == "success" then
      msg = (" Installed %s"):format(state.description)
    elseif state.status == "failed" then
      level = vim.log.levels.ERROR
      msg = ("✕ Failed to install %s"):format(state.description)
    else
      installing[id] = nil
      return
    end

    vim.notify(msg, level, {
      id = id,
    })

    if state.status == "installing" then
      monitor(id)
    end
  end, 80)
end

---@param pkg Package
---@param filetype string
---@param annotation? string|boolean
local function start(pkg, filetype, annotation)
  local id = pkg.spec.source.id
  if installing[id] then
    return
  end

  local description = ("%s%s for %s"):format(pkg.name, annotation and (" (" .. annotation .. ")") or "", filetype)
  installing[id] = {
    description = description,
    status = "installing",
  }

  monitor(id)
end

---@param pkg Package
local function success(pkg)
  local id = pkg.spec.source.id
  if not installing[id] then
    return
  end
  installing[id].status = "success"
end

local function failure(pkg)
  local id = pkg.spec.source.id
  if not installing[id] then
    return
  end
  installing[id].status = "failed"
end

---@param pkg? Package
---@param filetype string
---@param annotation? string|boolean
local function install_package(pkg, filetype, annotation)
  if not pkg or pkg:is_installed() or pkg:is_installing() then
    return
  end

  pkg
    :once("install:handle", function()
      start(pkg, filetype, annotation)
    end)
    :once("install:success", function()
      success(pkg)
    end)
    :once("install:failure", function()
      failure(pkg)
    end) --[[ @as Package ]]
    :install()
end

---@param filetype string
local function install_lsps(filetype)
  local function get_lsp_package(server_name)
    local pkg_name = require("mason-lspconfig").get_mappings().lspconfig_to_package[server_name]
    return get_package(pkg_name) or get_package(server_name)
  end

  ---@param server string
  local function install_lsp(server)
    local pkg = get_lsp_package(server)
    if not pkg or pkg:is_installed() or pkg:is_installing() then
      return
    end

    install_package(pkg, filetype, server ~= pkg.name and ("%s lsp"):format(server))
  end

  local servers = vim.tbl_keys(LazyVim.opts("nvim-lspconfig").servers)
  for _, server in ipairs(servers) do
    local config = vim.lsp.config[server] or {}
    if config.filetypes and vim.list_contains(config.filetypes, filetype) then
      install_lsp(server)
    end
  end
end

---@param names string[]
---@param filetype string
local function install_packages(names, filetype)
  for _, name in ipairs(names) do
    install_package(get_package(name), filetype)
  end
end

---@param filetype string
local function install_formatters(filetype)
  local formatters_by_ft = LazyVim.opts("conform.nvim").formatters_by_ft or {}
  local formatters = formatters_by_ft[filetype] or {}
  install_packages(formatters, filetype)
end

---@param filetype string
local function install_linters(filetype)
  local linters_by_ft = LazyVim.opts("formatters").linters_by_ft or {}
  local linters = linters_by_ft[filetype] or {}
  install_packages(linters, filetype)
end

---@param filetype string
local function install_daps(filetype)
  local dap_to_package = require("mason-nvim-dap.mappings.source").nvim_dap_to_package
  local function get_dap_package(dap_name)
    local pkg_name = dap_to_package[dap_name]
    return get_package(pkg_name) or get_package(dap_name)
  end

  local function install_dap(dap)
    local pkg = get_dap_package(dap)
    if not pkg or pkg:is_installed() or pkg:is_installing() then
      return
    end

    install_package(pkg, filetype, dap ~= pkg.name and ("%s dap"):format(dap))
  end

  local auto_install = LazyVim.opts("mason.nvim").chris468_auto_install
  local dap_to_filetypes = require("mason-nvim-dap.mappings.filetypes")
  vim
    .iter(dap_to_filetypes)
    :filter(function(dap, filetypes)
      return vim.list_contains(auto_install, dap_to_package[dap] or dap) and vim.list_contains(filetypes, filetype)
    end)
    :each(install_dap)
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("chris468.lsp", { clear = true }),
  callback = function(arg)
    local filetype = arg.match
    if installed_filetypes[filetype] then
      return
    end
    installed_filetypes[filetype] = true
    install_lsps(filetype)
    install_formatters(filetype)
    install_linters(filetype)
    install_daps(filetype)
  end,
})
