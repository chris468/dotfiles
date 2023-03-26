" Keyboard mappings:
" N                 I       Action
" ---------------------------------------------------------------------
" gd                -       go to definition
" gy                -       go to type definition
" gi                -       go to implementation
" gr                -       find references
" K                 -       show documentation for symbol under ursor
" <leader>rn        -       rename symbol under cursor
" <leader><leader>  -       show code actions
" <leader>s         <C-\>s  show signature help
" <leader>j         -       Next error/warn/etc
" <leader>k         -       Previous error/warn/etc
" <leader>p         -       Resume error/warn/etc (coc-specific?)

function! s:configure_language_service_mappings()
    if g:enable_ale && exists('g:loaded_ale')
        let b:language_service_mappings = 'ale'

        nmap <silent> <buffer> gd <Plug>(ale_go_to_definition)
        nmap <silent> <buffer> gD <Plug>(ale_go_to_definition_in_split)
        nmap <silent> <buffer> gy <Plug>(ale_go_to_type_definition)
        nmap <silent> <buffer> gY <Plug>(ale_go_to_type_definition_in_split)
        nmap <silent> <buffer> gi <Plug>(ale_go_to_implementation)
        nmap <silent> <buffer> gI <Plug>(ale_go_to_implementation_in_split)
        nmap <silent> <buffer> gr <Plug>(ale_find_references)

        nmap <silent> <buffer> K <Plug>(ale-hover)

        nmap <silent> <buffer> <leader>rn :ALERename<CR>
        nmap <silent> <buffer> <leader><leader> :ALECodeAction<CR>

        nmap <silent> <buffer> <leader>j <Plug>(ale_next)
        nmap <silent> <buffer> <leader>k <Plug>(ale_previous)
    endif
'
    if g:enable_coc && exists('g:did_coc_loaded')
        let b:language_service_mappings = 'coc'

        nmap <silent> <buffer> gd <Plug>(coc-definition)
        nmap <silent> <buffer> gD :call CocAction('jumpDefinition', 'pedit')<CR>
        nmap <silent> <buffer> gy <Plug>(coc-type-definition)
        nmap <silent> <buffer> gY :call CocAction('jumpTypeDefinition', 'pedit')<CR>
        nmap <silent> <buffer> gi <Plug>(coc-implementation)
        nmap <silent> <buffer> gI :call CocAction('jumpImplementation', 'pedit')<CR>
        nmap <silent> <buffer> gr <Plug>(coc-references)

        nmap <silent> <buffer> K :call ShowDocumentation()<CR>

        nmap <silent> <buffer> <leader>rn <Plug>(coc-rename)
        nmap <silent> <buffer> <leader><leader> <Plug>(coc-codeaction-cursor)
        xmap <silent> <buffer> <leader><leader> <Plug>(coc-codeaction-selected)

        nmap <silent> <buffer> <leader>j <Plug>(coc-diagnostic-next)
        nmap <silent> <buffer> <leader>k <Plug>(coc-diagnostic-previous)
    endif

    let l:omnisharp = g:enable_omnisharp && &filetype == 'cs' && exists('g:OmniSharp_loaded')
    if l:omnisharp
        " intentionally overriding some other shortcuts

        let b:language_service_mappings = 'omnisharp'
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

augroup LanguageServiceMappings
    autocmd!
    autocmd BufNew,BufEnter,BufAdd,BufCreate * call s:configure_language_service_mappings()
augroup end

