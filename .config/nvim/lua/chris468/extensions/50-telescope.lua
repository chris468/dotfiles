local if_ext = require 'chris468.util.if-ext'
if_ext('telescope', function(telescope)
  telescope.setup {
    defaults = {
      mappings = {
        i = {
          ['<C-J>'] = 'move_selection_next',
          ['<C-K>'] = 'move_selection_previous',
        },
        n = {
          ['<C-J>'] = 'move_selection_next',
          ['<C-K>'] = 'move_selection_previous',
        }
      }
    }
  }
end)
