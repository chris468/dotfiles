local global_options = {
  loaded_netrw = 1,
  loaded_netrwPlugin = 1
}

local options = {
  termguicolors = true
}

for k, v in pairs(global_options) do
  vim.g[k] = v
end

for k, v in pairs(options) do
  vim.opt[k] = v
end
