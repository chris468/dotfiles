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

local progress = {
  count = 0,
  total = 0,
  ---@type string[]
  _messages = {},
  error = false,
  ---@type table|boolean
  timer = false,
}

local function spinner()
  return require("noice.util.spinners").spin()
end

function progress.installing(display_name)
  if progress.count == progress.total then
    progress.count, progress.total = 0, 1
  else
    progress.total = progress.total + 1
  end
  progress.message(("  Installing %s"):format(display_name))
end

function progress.success(display_name)
  progress.count = progress.count + 1
  progress.message((" Installed %s"):format(display_name))
end

function progress.failed(display_name)
  progress.count = progress.count + 1
  progress.message(("✗ Failed to install %s"):format(display_name), true)
end

---@param status string
---@param error? boolean
function progress.message(status, error)
  table.insert(progress._messages, status)
  progress.error = progress.error or error or false

  local function last_messages(n)
    return table.concat(vim.tbl_values({ unpack(progress._messages, #progress._messages - (n - 1)) }), "\n")
  end

  local function notify(done)
    local title = done and (progress.error and "Language support installation failed" or "Language support installed")
      or ("Installing language support... (%d/%d)"):format(progress.count, progress.total)
    local icon = done and (progress.error and "✗" or "✓") or spinner()
    vim.schedule_wrap(vim.notify)(
      last_messages(5),
      progress.error and vim.log.levels.ERROR or vim.log.levels.INFO,
      { title = title, icon = icon, id = "chris468.lang", history = false }
    )
  end

  local function show()
    progress.timer = vim.defer_fn(function()
      if progress.total == 0 then
        return
      end
      if progress.count == progress.total then
        notify(true)
        progress.count, progress.total, progress.timer, progress._messages = 0, 0, false, {}
      else
        notify(false)
        progress.timer = show()
      end
    end, 80)
  end

  if not progress.timer then
    show()
  end
end

---@param pkg? Package
---@param annotation? string|boolean
local function install_package(pkg, annotation)
  if not pkg or pkg:is_installed() or pkg:is_installing() then
    return
  end

  local display_name = annotation and (("%s (%s)"):format(pkg.name, annotation)) or pkg.name

  pkg
    :once("install:handle", function()
      progress.installing(display_name)
    end)
    :once("install:success", function()
      progress.success(display_name)
    end)
    :once("install:failure", function()
      progress.failed(display_name)
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

    install_package(pkg, server ~= pkg.name and ("%s lsp"):format(server))
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
local function install_packages(names)
  for _, name in ipairs(names) do
    install_package(get_package(name))
  end
end

---@param filetype string
local function install_formatters(filetype)
  local formatters_by_ft = LazyVim.opts("conform.nvim").formatters_by_ft or {}
  local formatters = formatters_by_ft[filetype] or {}
  install_packages(formatters)
end

---@param filetype string
local function install_linters(filetype)
  local linters_by_ft = LazyVim.opts("formatters").linters_by_ft or {}
  local linters = linters_by_ft[filetype] or {}
  install_packages(linters)
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

    install_package(pkg, dap ~= pkg.name and ("%s dap"):format(dap))
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
