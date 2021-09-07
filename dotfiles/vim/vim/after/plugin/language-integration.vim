function! s:coc_show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

function! s:configure_omnisharp()
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
endfunction


function! s:configure_coc()
    let b:language_service = 'coc'
    nmap <silent> <buffer> gd <Plug>(coc-definition)
    nmap <silent> <buffer> gy <Plug>(coc-type-definition)
    nmap <silent> <buffer> gi <Plug>(coc-implementation)
    nmap <silent> <buffer> gr <Plug>(coc-references)

    nmap <silent> <buffer> K :call <SID>coc_show_documentation()<CR>

    nmap <silent> <buffer> <leader>rn <Plug>(coc-rename)
    nmap <silent> <buffer> <leader><leader> <Plug>(coc-codeaction)
    nmap <silent> <buffer> <leader>s :call CocActionAsync('showSignatureHelp')
    imap <silent> <buffer> <C-\>s <C-O>:call CocActionAsync('showSignatureHelp')

    nnoremap <silent><nowait> <space>j :<C-u>CocNext<CR>
    nnoremap <silent><nowait> <space>k :<C-u>CocPrev<CR>
    nnoremap <silent><nowait> <space>p :<C-u>CocListResume<CR>

endfunction

function! s:configure_ale()
    let b:language_service = 'ale'
    nmap <silent> <buffer> gd <Plug>(ale_go_to_definition)
    nmap <silent> <buffer> gy <Plug>(ale_go_to_type_definition)
    " nmap <silent> <buffer> gi <Plug>( " ??? )
    nmap <silent> <buffer> gr <Plug>(ale_find_references)

    nmap <silent> <buffer> K <Plug>(ale-hover)

    nmap <silent> <buffer> <leader>rn :ALERename<CR>
    nmap <silent> <buffer> <leader><leader> :ALECodeAction<CR>
endfunction

function! s:configure_language_integration()
    if &filetype == 'cs'
        call s:configure_omnisharp()
    elseif index(keys(g:ale_linters), &filetype) == -1
        call s:configure_coc()
    else
        call s:configure_ale()
    endif
endfunction

augroup LanguageIntegration
    autocmd!
    autocmd BufNew,BufEnter,BufAdd,BufCreate * call s:configure_language_integration()
augroup end

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

