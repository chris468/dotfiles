local if_ext = require 'chris468.util.if-ext'
if_ext ({'project_nvim', 'telescope'}, function(project, telescope)
  project.setup { manual_mode = true }
  telescope.load_extension('projects')
end)

