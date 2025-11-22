local M = {}
---@type table<string, true>
M.failed = {}

---@type table<string, string[]>
M.to_install = {}

---@type table<string, "already"|"success"|"fail"|"missing_prerequisite">
M.installed = {}

---@type table<integer, table<string, true>>
M.installing = {}

local function notify(message, level, opts)
  vim.schedule(function()
    vim.notify(message, level, opts)
  end)
end

---@param package_name string
---@param callback fun(package_name: string)
local function install_package(package_name, callback)
  local registry = require("mason-registry")
  local ok, package = pcall(registry.get_package, package_name)
  if ok then
    if package:is_installed() then
      M.installed[package_name] = "already"
      callback(package_name)
      return
    end

    local check_prerequisite = M.prerequisites[package_name] or function() return true, "" end
    local can_install, prerequisite = check_prerequisite()
    if not can_install then
      M.installed[package_name] = "missing_prerequisite"
      notify("Missing prerequisite for " .. package_name .. ": " .. prerequisite, vim.log.levels.WARN)
      callback(package_name)
      return
    end

    notify("Installing " .. package_name)
    package
      :once("install:success", function()
        notify("Successfully installed " .. package_name)
        M.installed[package_name] = "success"
        callback(package_name)
      end)
      :once("install:failed", function()
        notify("Error installing " .. package_name, vim.log.levels.WARN)
        M.installed[package_name] = "fail"
        callback(package_name)
      end)
    package:install()
  end
end

---@param buf integer
---@param package_names string[]
---@param done fun()
local function install_packages(buf, package_names, done)
  ---@type table<string, true>
  for _, name in ipairs(package_names) do
    M.installing[buf][name] = true
    install_package(name, function(n)
      M.installing[buf][n] = nil
      if done and vim.tbl_isempty(M.installing[buf]) then
        done()
      end
    end)
  end
end

---@param buf integer
---@param filetype string
local function install_packages_for_filetype(buf, filetype)
  if M.installing[buf] then
    return
  end

  M.installing[buf] = {}

  local packages = {}
  if M.to_install[filetype] or M.to_install["*"] then
    vim.list_extend(packages, M.to_install[filetype] or {})
    vim.list_extend(packages, M.to_install["*"] or {})
    M.to_install[filetype] = nil
    M.to_install["*"] = nil
    install_packages(buf, packages, function()
      vim.defer_fn(function()
        vim.api.nvim_exec_autocmds("FileType", {
          buffer = buf,
        })
      end, 100)
    end)
  end
end

---@param packages_by_filetype table<string, string[]>
---@param prerequisites table<string, fun():boolean, string>
function M.register(packages_by_filetype, prerequisites)
  M.to_install = packages_by_filetype
  M.prerequisites = prerequisites
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("lazy-mason-install", { clear = true }),
    callback = function(arg)
      local filetype = arg.match
      local buf = arg.buf
      install_packages_for_filetype(buf, filetype)
      return vim.tbl_isempty(M.to_install)
    end,
  })
end

return M
