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

let mapleader = " "

nnoremap <leader>et :NERDTreeToggle<CR> " Explorer Toggle
nnoremap <leader>ef :NERDTreeFocus<CR> " Explorer Focus

function s:has_no_arguments()
    return argc() == 0
endfunction

function s:has_single_directory_argument()
    return argc() == 1 && isdirectory(argv()[0])
endfunction

function s:show_explorer_on_launch()
    if exists('s:std_in') || v:this_session != ''
        return
    endif

    if s:has_no_arguments()
        NERDTree
        wincmd p
    endif

    if s:has_single_directory_argument()
        execute 'NERDTree' argv()[0]
        wincmd p
        enew
        execute 'cd '.argv()[0]
    endif
endfunction

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * call s:show_explorer_on_launch()
