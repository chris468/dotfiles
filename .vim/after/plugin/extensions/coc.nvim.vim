" Keyboard mappings:
" N                 I       Action
" ---------------------------------------------------------------------
" -                 <C-j>   Show completion menu / Next completion item
" -                 <C-k>   Previous completion item
" -                 <CR>    Accept completion
" -                 <Esc>   Cancel completion

if !exists('g:did_coc_loaded') | finish | endif

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <C-j>
  \ coc#pum#visible() ? coc#pum#next(1) :
  \ <SID>check_back_space() ? "\<C-j>" :
  \ coc#refresh()

inoremap <silent><expr> <Down>
  \ coc#pum#visible() ? coc#pum#next(1) :
  \ <SID>check_back_space() ? "\<Down>" :
  \ coc#refresh()

inoremap <expr> <C-k> coc#pum#visible() ? coc#pum#prev(1) : "\<C-k>"
inoremap <expr> <Up> coc#pum#visible() ? coc#pum#prev(1) : "\<Up>"

inoremap <silent><expr> <C-c> coc#pum#visible() ? coc#pum#cancel() : "\<C-c>"

inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

" inoremap <silent><expr> <Esc> coc#pum#visible() ? coc#pum#cancel() : "\<Esc>"

