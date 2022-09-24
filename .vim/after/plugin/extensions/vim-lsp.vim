"function! s:on_lsp_buffer_enabled() abort
"    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
"    setlocal omnifunc=lsp#complete
"  x nmap <silent> <buffer> gd <plug>(lsp-definition)
"  x nmap <silent> <buffer> gr <plug>(lsp-references)
"  x nmap <silent> <buffer> gi <plug>(lsp-implementation)
"  x nmap <silent> <buffer> gt <plug>(lsp-type-definition)
"  x nmap <silent> <buffer> <leader>rn <plug>(lsp-rename)
"    nmap <silent> <buffer> [g <plug>(lsp-previous-diagnostic)
"    nmap <silent> <buffer> ]g <plug>(lsp-next-diagnostic)
"  x nmap <silent> <buffer> K <plug>(lsp-hover)
"  x nmap <silent> <buffer> <leader>a <plug>(lsp-code-action)
"    nmap <silent> <buffer> <leader>s <plug>(lsp-signature-help)
"    imap <silent> <buffer> <C-\>s <C-O><plug>(lsp-signature-help)
"endfunction
