local if_ext = require 'chris468.util.if-ext'
if_ext ({'project_nvim', 'telescope'}, function(project, telescope)
  project.setup {
    scope_chdir = 'tab',
    exclude_dirs = {
      vim.fn.stdpath('data') .. '/*'
    }
  }
  telescope.load_extension('projects')
end)

