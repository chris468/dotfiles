set nobackup
set nowrap

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
set ts=4
set sw=4
set et
set hlsearch
set ignorecase
set smartcase

autocmd Filetype css setlocal ts=2 sw=2 et
autocmd Filetype json setlocal ts=2 sw=2 et
autocmd Filetype typescript setlocal ts=2 sw=2 et
autocmd Filetype javascript setlocal ts=4 sw=4 et
autocmd Filetype xml setlocal ts=2 sw=2 et
autocmd Filetype html setlocal ts=2 sw=2 et
autocmd Filetype yaml setlocal ts=2 sw=2 et
autocmd Filetype tf setlocal ts=2 sw=2 et
