require 'chris468.util.if-ext' ('nvim-tree', function(nvim_tree)

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
          folder = {
            default = '\u{25b6}',
            open = '\u{25bd}',
            empty = '\u{25b6}',
            empty_open = '\u{25bd}',
            symlink = '\u{25b6}',
            symlink_open = '\u{25bd}',
          },
          git = {
          },
        },
      },
    }
  }

end)
