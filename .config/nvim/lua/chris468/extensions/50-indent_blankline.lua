local if_ext = require("chris468.util.if-ext")
if_ext("indent_blankline", function(indent_blankline)
    indent_blankline.setup({
        sho_end_of_line = true,
        show_current_context = true,
    })
end)
