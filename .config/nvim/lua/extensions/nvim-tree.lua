local status_ok, nvim_tree = pcall(require, 'nvim-tree')
if not status_ok then
  return false
end

nvim_tree.setup()
return true
