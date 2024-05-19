local plugin_updates = {
  ["folke/trouble.nvim"] = {
    ["<leader>xx"] = "<leader>xX",
    ["<leader>xX"] = "<leader>xx",
  },
  ["nvim-telescope/telescope.nvim"] = {
    ["<leader>ss"] = "<leader>sS",
    ["<leader>sS"] = "<leader>ss",
  },
}

local function update(updates)
  return function(_, keys)
    for _, k in ipairs(keys) do
      local u = updates[k[1]]
      if u then
        k[1] = u
      end
    end
  end
end

local plugins = {}
for p, u in pairs(plugin_updates) do
  local plugin = {
    p,
    keys = update(u),
  }
  plugins[#plugins + 1] = plugin
end

return plugins
