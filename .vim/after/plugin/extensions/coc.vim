" disabled for now
finish

function! s:coc_show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

function! s:configure_coc()
    if index(keys(g:ale_linters), &filetype) == -1
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

        inoremap <silent><expr> <C-j>
              \ coc#pum#visible() ? coc#pum#next(1) :
              \ CheckBackspace() ? "\<C-j>" :
              \ coc#refresh()
        inoremap <expr><C-k> coc#pum#visible() ? coc#pum#prev(2) : "\<C-k>"

        inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

        inoremap <silent><expr> <Esc> coc#pum#visible() ? coc#pum#cancel() : "\<Esc>"


        function! CheckBackspace() abort
          let col = col('.') - 1
          return !col || getline('.')[col - 1]  =~# '\s'
        endfunction

        " Use <c-space> to trigger completion.
        if has('nvim')
          inoremap <silent><expr> <c-space> coc#refresh()
        else
          inoremap <silent><expr> <c-@> coc#refresh()
        endif
    endif
endfunction

augroup CocConfiguration
    autocmd!
    autocmd BufNew,BufEnter,BufAdd,BufCreate * call s:configure_coc()
augroup end

