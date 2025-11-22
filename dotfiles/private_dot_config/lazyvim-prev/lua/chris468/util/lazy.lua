local M = {}

---Gets the merged options for a lazy plugin
---@param name string
---@return table
function M.get_plugin_opts(name)
  local config = require("lazy.core.config")
  local plugin = require("lazy.core.plugin")

  local lazy_plugin = config.plugins[name]
  local opts = plugin.values(lazy_plugin, "opts")

  return opts
end

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

return M
