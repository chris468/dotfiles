if exists("g:vsvim")
    finish
endif

set signcolumn=yes

let g:lsp_diagnostics_echo_cursor = 1

function! s:on_lsp_buffer_enabled() abort
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    setlocal omnifunc=lsp#complete
    nmap <silent> <buffer> gd <plug>(lsp-definition)
    nmap <silent> <buffer> gr <plug>(lsp-references)
    nmap <silent> <buffer> gi <plug>(lsp-implementation)
    nmap <silent> <buffer> gt <plug>(lsp-type-definition)
    nmap <silent> <buffer> <leader>rn <plug>(lsp-rename)
    nmap <silent> <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <silent> <buffer> ]g <plug>(lsp-next-diagnostic)
    nmap <silent> <buffer> K <plug>(lsp-hover)
    nmap <silent> <buffer> <leader>a <plug>(lsp-code-action)
    nmap <silent> <buffer> <leader>s <plug>(lsp-signature-help)
    imap <silent> <buffer> <C-\>s <C-O><plug>(lsp-signature-help)
endfunction

augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
