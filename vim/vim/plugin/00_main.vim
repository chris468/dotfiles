if exists("g:vsvim")
    finish
endif

source $VIMRUNTIME/defaults.vim

set nobackup

set nowrap

set background=dark
let g:dracula_italic = 0
silent! colors dracula

" disiable bell completely (not audible or visual)
set visualbell t_vb=

let mapleader = " "
