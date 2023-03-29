-- set termguicolors to enable highlight groups
-- vim.opt.termguicolors = true

-- empty setup using defaults
require("nvim-tree").setup()
api.tree.open()

-- OR setup with some options
-- require("nvim-tree").setup({
--   sort_by = "case_sensitive",
--   renderer = {
--     group_empty = true,
--   },
--   filters = {
--     dotfiles = true,
--   },
-- })
