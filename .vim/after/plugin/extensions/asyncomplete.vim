" Keyboard mappings:
" N                 I       Action
" ---------------------------------------------------------------------
" -                 <C-j>   Show completion menu / Next completion item
" -                 <C-k>   Previous completion item
" -                 <CR>    Accept completion
" -                 <Esc>   Cancel completion

if !exists('g:asyncomplete_loaded') | finish | endif

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <C-j>
  \ pumvisible() ? "\<C-n>" :
  \ <SID>check_back_space() ? "\<C-j>" :
  \ asyncomplete#force_refresh()


inoremap <expr><C-k> pumvisible() ? "\<C-p>" : "\<C-k>"
