require("chris468.util.if-ext")("nvim-tree", function(nvim_tree)
    local symbols = require("chris468.util.symbols")

    nvim_tree.setup({
        sync_root_with_cwd = true,
        view = {
            number = true,
            relativenumber = true,
        },
        git = {
            show_on_open_dirs = false,
        },
        modified = {
            enable = true,
            show_on_open_dirs = false,
        },
        diagnostics = {
            enable = true,
            show_on_dirs = true,
            show_on_open_dirs = false,
            severity = {
                min = vim.diagnostic.severity.WARN,
                max = vim.diagnostic.severity.ERROR,
            },
            icons = {
                warning = symbols.warning,
                error = symbols.error,
            },
        },
        renderer = {
            group_empty = true,
            full_name = true,
            indent_markers = {
                enable = true,
                icons = {
                    item = "├",
                },
            },
            icons = {
                modified_placement = "signcolumn",
                show = {
                    file = false,
                    folder_arrow = false,
                    modified = true,
                },
                glyphs = {
                    bookmark = symbols.bookmark,
                    symlink = "",
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
        },
    })
end)
