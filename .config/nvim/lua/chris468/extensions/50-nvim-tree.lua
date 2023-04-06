require 'chris468.util.if-ext' ('nvim-tree', function(nvim_tree)

  local symbols = require 'chris468.util.symbols'

  nvim_tree.setup {
    git = {
      show_on_open_dirs = false,
    },
    renderer = {
      group_empty = true,
      full_name = true,
      indent_markers = {
        enable = true,
        icons = {
          item = '├',
        }
      },
      icons = {
        show = {
          file = false,
          folder_arrow = false,
        },
        glyphs = {
          bookmark = symbols.bookmark,
          folder = {
            default = symbols.folder_closed,
            open = symbols.folder_open,
            empty = symbols.folder_closed,
            empty_open = symbols.folder_open,
            symlink = symbols.folder_closed,
            symlink_open = symbols.folder_open,
          },
          git = {
            unstaged = "~",
            staged = "~",
            deleted = "✗",
          },
        },
      },
    }
  }

end)
