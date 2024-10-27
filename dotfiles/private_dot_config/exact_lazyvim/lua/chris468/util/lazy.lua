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

return M
