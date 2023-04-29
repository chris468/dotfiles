if &term == 'win32' && !empty($WT_SESSION)
    silent! set termguicolors
endif

set background=dark
let g:dracula_italic = 0
silent! colors dracula
set cursorline

" disiable bell completely (not audible or visual)
set visualbell t_vb=

set number
set relativenumber
set signcolumn=yes

