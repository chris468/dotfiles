let s:vim_plug_path = expand('<sfile>:p:h') . '/../plugged'

function! extensions#load()

    call plug#begin(s:vim_plug_path)
        Plug 'dracula/vim'

        Plug 'tpope/vim-surround'
        Plug 'ctrlpvim/ctrlp.vim'

        Plug 'prabirshrestha/vim-lsp'
        Plug 'mattn/vim-lsp-settings'
        Plug 'prabirshrestha/asyncomplete.vim'
        Plug 'prabirshrestha/asyncomplete-lsp.vim'

        Plug 'puremourning/vimspector'
    call plug#end()

endfunction

