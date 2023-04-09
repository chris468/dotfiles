local project = require 'project_nvim'
local telescope = require 'telescope'

project.setup {
  scope_chdir = 'tab',
  exclude_dirs = {
    vim.fn.stdpath('data') .. '/*'
  }
}

telescope.load_extension('projects')
