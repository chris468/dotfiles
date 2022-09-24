if !exists('g:loaded_ale') | finish | endif

function! s:configure_ale()
    if &filetype != 'cs' " && index(keys(g:ale_linters), &filetype) == -1
        let b:language_service = 'ale'
        nmap <silent> <buffer> gd <Plug>(ale_go_to_definition)
        nmap <silent> <buffer> gy <Plug>(ale_go_to_type_definition)
        " nmap <silent> <buffer> gi <Plug>( " ??? )
        nmap <silent> <buffer> gr <Plug>(ale_find_references)

        nmap <silent> <buffer> K <Plug>(ale-hover)

        nmap <silent> <buffer> <leader>rn :ALERename<CR>
        nmap <silent> <buffer> <leader><leader> :ALECodeAction<CR>
    endif
endfunction

augroup AleConfiguration
    autocmd!
    autocmd BufNew,BufEnter,BufAdd,BufCreate * call s:configure_ale()
augroup end
