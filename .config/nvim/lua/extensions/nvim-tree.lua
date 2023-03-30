local status_ok, nvim_tree = pcall(require, 'nvim-tree')
if not status_ok then
  return
end


-- empty setup using defaults
nvim_tree.setup()

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
