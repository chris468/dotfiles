local status_ok, cmp = pcall(require, 'nvim-cmp')
if not status_ok then
  return
end

local status_ok, _ = pcall(require, 'cmp_nvim_lsp')
if not status_ok then
  return
end

cmp.setup {
  sources = {
    name = 'nvim_lsp'
  }
}
