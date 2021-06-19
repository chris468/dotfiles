if exists("g:vsvim")
    finish
endif

set signcolumn=yes

packadd ale
packadd asyncomplete.vim
packadd ctrlp.vim
packadd vim-snippets

if has('python3')
    runtime omnisharp-config.vim
    packadd omnisharp-vim
    packadd ultisnips
    packadd vim-sharpenup
endif

let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"
