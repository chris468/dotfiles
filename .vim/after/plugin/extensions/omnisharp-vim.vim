if !exists('g:OmniSharp_loaded') | finish | endif

function! s:configure_omnisharp()
    if &filetype == 'cs'
        let b:language_service = 'omnisharp'
        nmap <silent> <buffer> gd <Plug>(omnisharp_go_to_definition)
        " nmap <silent> <buffer> gy " None
        nmap <silent> <buffer> gi <Plug>(omnisharp_find_implementations)
        nmap <silent> <buffer> gr <Plug>(omnisharp_find_usages)

        nmap <silent> <buffer> K <Plug>(omnisharp_type_lookup)

        nmap <silent> <buffer> <leader>rn <Plug>(omnisharp-rename)
        nmap <silent> <buffer> <leader><leader> <Plug>(omnisharp_code_actions)
        nmap <silent> <buffer> <leader>s <Plug>(omnisharp_signature_help)
        imap <silent> <buffer> <C-\>s <Plug>(omnisharp_signature_help)
    endif
endfunction

augroup OmniSharpConfiguration
    autocmd!
    autocmd BufNew,BufEnter,BufAdd,BufCreate * call s:configure_omnisharp()
augroup end

