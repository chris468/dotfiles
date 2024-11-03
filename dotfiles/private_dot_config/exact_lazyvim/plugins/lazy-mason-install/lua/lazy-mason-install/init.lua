local M = {}

---@class lazy-mason-install.Config
---@field packages_by_ft table<string, string[]>
---@field all string[]?

---@type lazy-mason-install.Config
local defaults = {
  packages_by_ft = {},
  all = { "*", "_" },
}

---@type lazy-mason-install.Config
local config

---@param user_config lazy-mason-install.Config
function M.setup(user_config)
  config = vim.tbl_deep_extend("keep", user_config, defaults)
  vim.notify("lazy-mason-install " .. vim.inspect(config))
end

return M
