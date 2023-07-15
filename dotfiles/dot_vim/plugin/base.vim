set nobackup
set nowrap
set noswapfile

set hlsearch
set ignorecase
set smartcase

set wildignore=**/bin/**,**/obj/**,*.nupkg,**/__pycache__/**,*.tfstate*

if (has('win32'))
    set encoding=utf-8
endif


nmap <silent> <leader>h :tabprev<CR>
nmap <silent> <leader>l :tabnext<CR>
nmap <silent> <leader>n :nohlsearch<CR>

nmap <silent> <leader>R :call chris468#temporarily_show_absolute_line_numbers()<CR>
