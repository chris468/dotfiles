local M = {}

function M.install()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({
        { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
        { out, "WarningMsg" },
        { "\nPress any key to exit..." },
      }, true, {})
      vim.fn.getchar()
      os.exit(1)
    end
  end
  vim.opt.rtp:prepend(lazypath)
end

---@param name string
---@return LazyPlugin
function M.plugin(name)
  return require("lazy.core.config").spec.plugins[name]
end

---@param name string
---@return boolean
function M.has_plugin(name)
  return M.plugin(name) ~= nil
end

---@param name string
---@return table
function M.opts(name)
  local plugin_api = require("lazy.core.plugin")
  return plugin_api.values(M.plugin(name), "opts")
end

return M
