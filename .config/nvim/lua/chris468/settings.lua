local global_options = {
  dracula_italic = 0,
  loaded_netrw = 1,
  loaded_netrwPlugin = 1,
}

local options = {
  background = dark,
  backup = false,
  cursorline = true,
  directory = vim.fn.stdpath('cache')..'/swp/',
  encoding = 'utf-8',
  expandtab = true,
  hlsearch = true,
  ignorecase = true,
  number = true,
  relativenumber = true,
  shiftwidth = 4,
  signcolumn = 'yes',
  smartcase = true,
  tabstop = 4,
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
