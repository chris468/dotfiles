set nobackup
set nowrap
set directory=~/.cache/swp//

set hlsearch
set ignorecase
set smartcase

if (has('win32'))
    set encoding=utf-8
endif


nmap <silent> <leader>h :tabprev<CR>
nmap <silent> <leader>l :tabnext<CR>
