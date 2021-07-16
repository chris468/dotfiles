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

if (has('win32'))
    set encoding=utf-8
endif

let g:vimspector_enable_mappings = 'VISUAL_STUDIO'

let g:ctrlp_root_markers = [ '*.sln' ]

" Don't require explicit selection
let g:asyncomplete_auto_completeopt = 0
set completeopt=menuone,noinsert

" Enable syntax folding
set foldmethod=expr
set foldexpr=lsp#ui#vim#folding#foldexpr()
set foldtext=lsp#ui#vim#folding#foldtext()

" Show fold indication
set foldcolumn=2

" Open files with all folds expanded
set foldlevelstart=99

" Preserve fold levels
" https://stackoverflow.com/questions/37552913/vim-how-to-keep-folds-on-save
set viewoptions=folds
augroup remember_folds
  autocmd!
  autocmd BufWinLeave * silent! mkview
  autocmd BufWinEnter * silent! loadview
augroup END
