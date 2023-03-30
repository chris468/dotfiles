local global_options = {
  loaded_netrw = 1,
  loaded_netrwPlugin = 1
}

local options = {
  backup = false,
  directory = vim.fn.stdpath('cache')..'/swp/',
  encoding = 'utf-8',
  hlsearch = true,
  ignorecase = true,
  smartcase = true,
  termguicolors = true,
  wildignore = '**/bin/**,**/obj/**,*.nupkg,**/__pycache__/**,*.tfstate*',
  wrap = false,
}

for k, v in pairs(global_options) do
  vim.g[k] = v
end

for k, v in pairs(options) do
  vim.opt[k] = v
end
