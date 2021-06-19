" These should be simple configuration applicable to every client, including
" vsvim. vsvim has limited functionality and includes this file.

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
