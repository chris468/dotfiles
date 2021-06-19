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

" netrw config
let g:netrw_liststyle = 3 " tree style listing
let g:netrw_winsize = 25
