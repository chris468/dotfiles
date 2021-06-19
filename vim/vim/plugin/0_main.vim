if exists("g:vsvim")
    finish
endif

source $VIMRUNTIME/defaults.vim

set nobackup

set background=dark
colors dracula

" netrw config
let g:netrw_liststyle = 3 " tree style listing
let g:netrw_winsize = 25
