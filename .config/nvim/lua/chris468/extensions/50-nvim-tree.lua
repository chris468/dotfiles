require 'chris468.util.if-ext' ('nvim-tree', function(nvim_tree)

  local symbols = require 'chris468.util.symbols'

  nvim_tree.setup {
    renderer = {
      group_empty = true,
      full_name = true,
      indent_width = 1,
      indent_markers = {
        enable = true,
        inline_arrows = false,
      },
      icons = {
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
          },
        },
      },
    }
  }

end)
