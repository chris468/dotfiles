local status_ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if not status_ok then
  return
end

require('lspconfig').pyright.setup {
  capabilities = cmp_nvim_lsp.default_capabilities()
}
