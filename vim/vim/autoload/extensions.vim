let s:vim_plug_path = expand('<sfile>:p:h') . '/../plugged'

function! extensions#load()
  call plug#begin(s:vim_plug_path)
  Plug 'tpope/vim-surround'
  call plug#end()
endfunction

